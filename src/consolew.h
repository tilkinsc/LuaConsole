/* MIT License
 * 
 * Copyright (c) 2017-2019 Cody Tilkins
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#pragma once



// REPL line buffer length
#define REPL_BUFFER_SIZE			(2048)
#define PRIMARY_REPL_BUFFER_SIZE	(REPL_BUFFER_SIZE + 1)			// for `\0`
#define SECONDARY_REPL_BUFFER_SIZE	(PRIMARY_REPL_BUFFER_SIZE + 8)	// for `return ;`


// controls verbosity of error output (0 off) (1 traceback) (2 stack_dump)
#define DO_VERBOSE_ERRORS			(2)

// controls whether boolean and number should be tostring'd if return non-string error
#define DO_EXT_ERROR_RETS			(0)


#define _(str) langfile_get(lang, str)


#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <fcntl.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "ldata.h"


// lang cache
extern LangCache* lang;


// buffers for REPL
static char* input = NULL;
static char* retfmt = NULL;

// flag for closing REPL
static int should_close = 0;


// internal enums, represents lua error category
typedef enum LuaConsoleError {
	INTERNAL_ERROR = 0,
	SYNTAX_ERROR = 1,
	RUNTIME_ERROR = 2,
} LuaConsoleError;



// prints out anything left on the stack in a verbose way
static inline int stack_dump(lua_State* L) {
	int i = lua_gettop(L);
	printf(_("STACK_DUMP_BEGIN"));
	while(i) {
		int t = lua_type(L, i); // get type number
		switch (t) { // switch type number
		case LUA_TSTRING:
			fprintf(stdout, _("SD_STRING"), i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			fprintf(stdout, _("SD_BOOL"), i, lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			fprintf(stdout, _("SD_NUMB"), i, lua_tonumber(L, i));
			break;
		case LUA_TFUNCTION:
			fprintf(stdout, _("SD_FUNC"), i, lua_topointer(L, i));
			break;
		case LUA_TTABLE:
			fprintf(stdout, _("SD_TABLE"), i, lua_topointer(L, i));
			break;
		case LUA_TUSERDATA:
			fprintf(stdout, _("SD_UD"), i, lua_topointer(L, i));
			break;
		case LUA_TLIGHTUSERDATA:
			fprintf(stdout, _("SD_LUD"), i, lua_topointer(L, i));
			break;
		case LUA_TTHREAD:
			fprintf(stdout, _("SD_THREAD"), i, lua_topointer(L, i));
			break;
		case LUA_TNONE:
			fprintf(stdout, _("SD_NONE"), i);
			break;
		default:
			fprintf(stdout, _("SD_OBJ"), i, lua_typename(L, t), lua_topointer(L, i));
			break;
		}
		i--;
	}
	printf(_("STACK_DUMP_DONE"));
	return 0;
}



// easy macros for error handling
static inline void check_error_OOM(int cond, int line) {
	if(cond == 1) {
		fprintf(stderr, _("OOM_D"), line);
		exit(EXIT_FAILURE);
	}
}

static inline void check_error(int cond, const char* str) {
	if(cond == 1) {
		fputs(str, stderr);
		exit(EXIT_FAILURE);
	}
}



// returns a malloc'd string copy with each split item being separated by \0
// supersedes use of strtok, which brutalizes information we need
static inline char* strsplit(const char* str1, const char lookout,
		size_t len, size_t max)
{
	char* cpy = malloc(len);
	check_error_OOM(cpy == NULL, __LINE__);
	memcpy(cpy, str1, len);
	
	size_t temp_max = max;
	for(size_t i=0; i<len-1; i++) {
		if(str1[i] == lookout) {
			cpy[i] = '\0';
			max--;
		}
		if(max == 0)
			break;
	}
	if(temp_max == max) {
		free(cpy);
		return 0;
	}
	if(temp_max == 1) {
		free(cpy);
		return 0;
	}
	return cpy;
}

// gets the next string in array
// macro to get next string from strsplit
// WARNING: undefined behavior if used more times than strsplit splits
static inline char* strnxt(const char* str1) {
	return (char*) str1 + (strlen(str1) + 1);
}

// counts the number of 'char c' occurances in a string
// WARNING: while(1){} if non-null-terminal'd data chunk
static inline size_t strcnt(const char* str1, char c) {
	size_t count = 0;
	while(*str1++ != '\0' && (*str1 == c ? ++count : 1));
	return count;
}



// handles non-string errors
// if error message is not a string, execute a tostring on metatable if present
static inline const char* error_test_meta(const char** out_type) {
	const char* msg = lua_tostring(L, -1); // attempt tostring
	if(msg == NULL) { // if failed
		int meta = luaL_callmeta(L, -1, "__tostring"); // call metatable __tostring
		int ret = lua_type(L, -1); 
		if(meta != 0) {
			#if DO_EXT_ERROR_RETS == 1
				if(ret == LUA_TSTRING || (ret == LUA_TNUMBER || ret == LUA_TBOOLEAN))
					msg = lua_tostring(L, -1);
			#else
				if(ret == LUA_TSTRING)
					msg = lua_tostring(L, -1);
			#endif
		} else {
			msg = "Warning: Error return type is ";
			*out_type = luaL_typename(L, -1);
		}
	}
	return msg;
}

// handles in-lua runtime error messages
// returns/leaves 1 item on stack:
//		1. error message
static int lua_print_error(lua_State* L) {
	const char* type = "";
	const char* msg = error_test_meta(&type);
	
	#if DO_VERBOSE_ERRORS > 0
		lua_pop(L, 1); // err msg
		luaL_traceback(L, L, "--", 1);
		const char* tb = lua_tostring(L, -1);
	#endif
	
	size_t top = lua_gettop(L);
	fprintf(stderr, _("LUA_ERROR"), top, msg, type);
	#if DO_VERBOSE_ERRORS > 0
		fprintf(stderr, "%s\n", tb);
		#if DO_VERBOSE_ERRORS > 1
			if(top > 1)
				stack_dump(L);
		#endif
	#endif
	return 1;
}

// handles out-of-lua error messages
// leaves 1 item on stack:
//		1. error message
static inline void print_error(LuaConsoleError error, int offset) {
	switch(error) {
	case INTERNAL_ERROR:
		fprintf(stderr, _("LUA_ERROR_INTERNAL"));
		break;
	case SYNTAX_ERROR:
		fprintf(stderr, _("LUA_ERROR_SYNTAX"));
		break;
	case RUNTIME_ERROR:
		fprintf(stderr, _("LUA_ERROR_RUNTIME"));
		break;
	}
	const char* type = "";
	const char* msg = error_test_meta(&type);
	size_t top = lua_gettop(L);
	fprintf(stderr, _("LUA_ERROR_RAW"), top - offset, msg, type);
	#if DO_VERBOSE_ERRORS > 0
		if(top - offset > 1)
			stack_dump(L);
	#endif
}



// append parameters to the stack for a pcall to consume
static inline void inject_parameters() {
	for(size_t i=0; i<ARGS.parameters; i++)
		lua_pushlstring(L, ARGS.parameters_argv[i], strlen(ARGS.parameters_argv[i]));
}

// load parameters into global `arg` table
static inline void load_parameters() {
	lua_createtable(L, 0, (int)ARGS.parameters);
	for(size_t i=0; i<ARGS.parameters; i++) {
		lua_pushinteger(L, i+1);
		lua_pushlstring(L, ARGS.parameters_argv[i], strlen(ARGS.parameters_argv[i]));
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");
}



// handles line by line interpretation (REPL)
static int lua_main_postexist(lua_State* L) {
	input = malloc(PRIMARY_REPL_BUFFER_SIZE);
	retfmt = malloc(SECONDARY_REPL_BUFFER_SIZE);
	check_error_OOM(input == NULL || retfmt == NULL, __LINE__);
	
	int base = 0;
	int status = 0;
	unsigned int ch = 0;
	size_t i = 0;
	while(should_close != 1) {
retry:
		// 1. reset
		status = 0;
		i = 0;
		
		// 2. read
		fputs(">", stdout);
		while((ch = fgetc(stdin)) != '\n') {
			if(ch == -1) // sigint
				return luaL_error(L, _("SIGINT"));
			if(i == PRIMARY_REPL_BUFFER_SIZE - 1) { // if max input reached
				fputs(_("REPL_LINE_TOO_LONG"), stdout);
				fflush(stdin);
				goto retry;
			}
			input[i++] = ch;
		}
		input[i++] = '\0'; // ensure c-string format
		
		// 2.1 exit if requested
		if(memcmp(input, "return", 6 + 1) == 0) { // return\0 returns if without arguments 
			should_close = 1;
			return 0;
		}
		
		// 3. return %s; test
		snprintf(retfmt, SECONDARY_REPL_BUFFER_SIZE, "return %s;", input);
		status = luaL_loadbuffer(L, retfmt, strlen(retfmt), "REPL return");
		if(status != 0) {
			lua_pop(L, 1); // err msg
		} else {
			// attempt first test, return seems to work
			int top = lua_gettop(L);
			status = lua_pcall(L, 0, LUA_MULTRET, 0);
			if(status == 0) { // on success
				top = lua_gettop(L) - top + 1; // + 1 = ignore pushed function
				if(top > 0) { // more than 0 arguments returned
					lua_getglobal(L, "print");
					if(lua_isnil(L, -1) != 1) { // check even if no_libraries == 1
						lua_insert(L, lua_gettop(L)-top);
						lua_call(L, top, 0);
					} else
						lua_pop(L, 1 + top); // nil, anything returned
				}
				continue;
			} else lua_pop(L, 1); // err msg, also ignore it - no relevance
		}
		
		// 4. load and execute originally inserted code with error handler
		lua_pushcclosure(L, lua_print_error, 0);
		base = lua_gettop(L);
		if((status = luaL_loadbuffer(L, input, strlen(input), "REPL")) != 0) {
			print_error(SYNTAX_ERROR, 1);
			lua_pop(L, 2); // err msg, err handler
		} else {
			if((status = lua_pcall(L, 0, LUA_MULTRET, base)) != 0)
				lua_pop(L, 2); // err msg, err handler, also ignore it - no relevance
		}
	}
	
	return 0;
}



// handles execution of REPL
static inline int start_protective_mode_REPL() {
	signal(SIGINT, SIG_IGN); // SIGINT handled in lua_main_postexist
	
	lua_pushcclosure(L, lua_main_postexist, 0);
	int status = 0;
	if((status = lua_pcall(L, 0, 0, 0)) != 0) {
		print_error(INTERNAL_ERROR, 1);
		lua_pop(L, 1); // err msg
	}
	
	free(retfmt);
	free(input);
	return status;
}

// handles execution of strings
static inline int start_protective_mode_string(const char* str, size_t params) {
	signal(SIGINT, SIG_IGN); // Ignore for now
	
	lua_pushcclosure(L, lua_print_error, 0); // wrap in error handler
	int base = lua_gettop(L);
	int status = 0;
	if((status = luaL_loadbuffer(L, str, strlen(str), "execute")) != 0) {
		print_error(SYNTAX_ERROR, 1);
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	if(params > 0)
		inject_parameters();
	if((status = lua_pcall(L, (int)params, LUA_MULTRET, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	base = lua_gettop(L) - base; // nargs returned
	if(base > 0) { // print if returns are present
		lua_getglobal(L, "print");
		if(lua_isnil(L, -1) != 1) { // check even if no_libraries == 1
			lua_insert(L, lua_gettop(L) - base);
			lua_call(L, base, 0);
		} else
			lua_pop(L, 1 + base); // nil, anything returned
	}
	lua_pop(L, 1); // err handler
	return status;
}

// handles execution of files
static inline int start_protective_mode_file(const char* file, size_t params) {
	signal(SIGINT, SIG_IGN); // Ignore for now
	
	lua_pushcclosure(L, lua_print_error, 0); // wrap in error handler
	int base = lua_gettop(L);
	int status = 0;
	if((status = luaL_loadfile(L, file)) != 0) {
		print_error(SYNTAX_ERROR, 1);
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	if(params > 0)
		inject_parameters();
	if((status = lua_pcall(L, (int)params, 0, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}

// handles execution of anything to be required
static inline int start_protective_mode_require(const char* file) {
	signal(SIGINT, SIG_IGN); // Ignore for now
	
	lua_pushcclosure(L, lua_print_error, 0); // wrap in error handler
	int base = lua_gettop(L);
	lua_getglobal(L, "require");
	lua_pushlstring(L, file, strlen(file));
	int status = 0;
	if((status = lua_pcall(L, 1, 0, base)) != 0) { // execute require on string
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}



// parses globals dynamic array and sets up global variables properly
static inline void load_globals(Array* globals, void* data) {
	// split argument between '=', max is two (left and right)
	char* m_args = strsplit((char*) data, '=', strlen((char*) data) + 1, 2);
	check_error(m_args == NULL, _("GLOBALS_ERROR_BAD_D"));
	
	char* arg1 = m_args; // left arg of '='
	char* arg2 = strnxt(arg1); // right arg of '='
	
	size_t dot_count = strcnt(arg1, '.'); // count subtable tranversions
	if(dot_count == 0) { // if its just a set global
		lua_pushlstring(L, arg2, strlen(arg2));
		lua_setglobal(L, arg1);
	} else if(dot_count > 0) { // if there are subtables
		char* tabs = strsplit(arg1, '.', strlen(arg1) + 1, -1);
		check_error(tabs == NULL, _("GLOBALS_ERROR_PARSE_D"));
		
		lua_getglobal(L, tabs); // select first table, create if none
		int istab = lua_istable(L, -1);
		if(istab == 0) {
			lua_pop(L, 1); // nil
			lua_newtable(L);
		}
		
		char* cur_arg = tabs; // iterate through table
		for(size_t i=1; i<dot_count; i++) {
			cur_arg = strnxt(cur_arg);
			lua_getfield(L, -1, cur_arg);
			if(lua_istable(L, -1) == 0) {
				lua_pop(L, 1); // nil
				lua_newtable(L);
				lua_setfield(L, -2, cur_arg);
				lua_getfield(L, -1, cur_arg);
			}
		}
		lua_pushlstring(L, arg2, strlen(arg2));
		lua_setfield(L, -2, strnxt(cur_arg));
		lua_pop(L, (int)dot_count - 1); // everything but root table
		lua_setglobal(L, tabs);
		free(tabs);
	}
	free(m_args);
}

// loads libraries into lua_State by executing them
static inline void load_libraries(Array* libraries, void* data) {
	char* name = (char*) data;
	char* str1 = strsplit(name, '.', strlen(name), 2);
	if(str1 != 0) {
		char* str2 = strnxt(str1);
		if((memcmp(str2, "dll", 3) == 0 || memcmp(str2, "so", 2) == 0)) {
			if(ARGS.no_libraries == 0)
				start_protective_mode_require(str1);
			else
				fprintf(stderr, _("LIBRARIES_ERROR_START"),
								_("LIBRARIES_ERROR_1"),
								name,
								_("LIBRARIES_ERROR_END"));
			return;
		}
	}
	start_protective_mode_file(name,
		(ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
		
	free(str1);
}

