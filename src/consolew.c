/* MIT License
 * 
 * Copyright (c) 2017-2018 Cody Tilkins
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

// REPL line buffer length
#define REPL_BUFFER_SIZE			(1024)
#define PRIMARY_REPL_BUFFER_SIZE	(REPL_BUFFER_SIZE + 1)
#define SECONDARY_REPL_BUFFER_SIZE	(PRIMARY_REPL_BUFFER_SIZE + 8) // + 8 is for `return ;`


// dynamic array initialization sizes for darr's
#define DEFINES_INIT				(4)
#define DEFINES_EXPANSION			(4)

#define LIBRARIES_INIT				(2)
#define LIBRARIES_EXPANSION			(2)

// controls verbosity of error output (0 off) (1 traceback) (2 stack_dump)
#define DO_VERBOSE_ERRORS			(2)

// controls whether boolean and number should be tostring'd if error returns a non-string
#define DO_EXT_ERROR_RETS			(0)

// environment variable for lua usage
#define ENV_VAR						"LUA_INIT"


// standard libraries per OS
#if defined(linux) || defined(__linux__) || defined(__linux)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME 		""
#	define LUA_DLL_SO_NAME 			".so"
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME 		""
#	define LUA_DLL_SO_NAME 			".so"
#elif defined(__APPLE__) || defined(__MACH__)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME 		""
#	define LUA_DLL_SO_NAME 			".so"
#elif defined(_WIN32) || defined(_WIN64)
#	include <windows.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY _isatty(_fileno(stdin))
#	define LUA_BIN_EXT_NAME 		".exe"
#	define LUA_DLL_SO_NAME 			".dll"
#else
#	error "OS not familiar. Set up headers accordingly, or -D__linux__ or -Dunix or -D__APPLE__ or -D_WIN32"
#endif


// stdlib includes
#include <dirent.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>



// compiler/project includes
// Please migrate your lua h's to a proper directory so versions don't collide
//   luajit `make install` puts them in /usr/local/include/luajit-X.X/*
//   lua51/52/53 `make install` puts them in /usr/local/include/* with version collision
#if defined(LUA_51)
#	include "lua51/lua.h"
#	include "lua51/lualib.h"
#	include "lua51/lauxlib.h"
#elif defined(LUA_52)
#	include "lua52/lua.h"
#	include "lua52/lualib.h"
#	include "lua52/lauxlib.h"
#elif defined(LUA_53)
#	include "lua53/lua.h"
#	include "lua53/lualib.h"
#	include "lua53/lauxlib.h"
#elif defined(LUA_JIT_51)
#	include "luajit-2.0/lua.h"
#	include "luajit-2.0/lualib.h"
#	include "luajit-2.0/lauxlib.h"
#	include "luajit-2.0/luajit.h"
#	include "jitsupport.h"
// TODO: support latest version of luajit
#else
#	warning "Lua version not defined."
#	error "Define the version to use. '-DLUA_53' '-DLUA_52' '-DLUA_51' '-DLUA_JIT_51'"
#endif


// local src includes
#include "darr.h"



// copyright information
#define LUA_CONSOLE_COPYRIGHT	"LuaConsole Copyright (C) 2017-2018, Cody Tilkins"



// usage message
const char HELP_MESSAGE[] =
	"LuaConsole | Version: 8/21/2018\n\n"
	LUA_VERSION " " LUA_COPYRIGHT
	"\n"
	LUA_CONSOLE_COPYRIGHT
	"\n"
	#if defined(LUA_JIT_51)
		LUAJIT_VERSION " " LUAJIT_COPYRIGHT " " LUAJIT_URL
		"\n"
	#endif
	"\nSupports Lua5.3, Lua5.2, Lua5.1, LuaJIT5.1\n"
	"\n"
	"Usage: luaw" LUA_BIN_EXT_NAME " [FILES] [-v] [-r] [-R] [-s PATH] [-p] [-c] [-Dvar=val]\n"
	"\t[-Dtb.var=val] [-Lfile.lua] [-Llualib" LUA_DLL_SO_NAME "] [-t{a,b}] [-r \"string\"]\n"
	"\t[-R \"string\"] "
		#if defined(LUA_JIT_51)
			"[-j{cmd,cmd=arg},...]\n\t[-O{level,+flag,-flag,cmd=arg}] [-b{l,s,g,n,t,a,o,e,-} {IN,OUT}]\n\t"
		#endif
		"[-?] [-n {arg1 ...}]\n"
	"\n"
	"-v \t\tPrints the Lua version in use\n"
	"-r \t\tPrevents lua core libraries from loading\n"
	"-R \t\tPrevents lua environment variables from loading\n"
	"-s \t\tIssues a new current directory\n"
	"-p \t\tActivates REPL mode after all or no supplied scripts\n"
	"-c \t\tNo copyright on init\n"
	"-d \t\tDefines a global variable as value after '='\n"
	"-l \t\tExecutes a module before specified script or post-exist\n"
	"-t[a,b] \tLoads parameters after -l's and -e\n"
		"\t\t\t[a]=delay arg table for file. [b]=no tuples\n"
	"-e \t\tExecutes a string as Lua Code BEFORE -l's\n"
	"-E \t\tExecutes a string as Lua Code AFTER -l's\n"
	"-  \t\tProcesses input from stdin\n"
	"-- \t\tStops processing parameters\n"
	#if defined(LUA_JIT_51)
		"-j \t\t LuaJIT  Performs a control command loads an extension module\n"
		"-O \t\t LuaJIT  Sets an optimization level/parameters\n"
		"-b \t\t LuaJIT  Saves or lists bytecode\n"
	#endif
	"-? --help \tDisplays this help message\n"
	"-n \t\tStart of parameter section\n";



#if defined(LUA_JIT_51)
	#include "jitsupport.h"
#endif



// struct for args to be seen across functions
static struct {
	size_t file_count;
	size_t parameters;
	char* start;
	char* run_str;
	Array* globals;
	Array* libraries;
	char** parameters_argv;
	#if defined(LUA_JIT_51)
		Array* luajit_jcmds;
		Array* luajit_opts;
		char** luajit_bc;
	#endif
	int do_stdin;
	int restore_console;
	int print_version;
	int post_exist;
	int no_file;
	int copyright_squelch;
	int run_after_libs;
	int delay_parameters;
	int no_tuple_parameters;
	int no_env_var;
	int no_libraries;
} ARGS;

// one environment per process
static lua_State* L = NULL;

// buffers for REPL
static char* input = NULL;
static char* retfmt = NULL;

// flag for closing REPL
static int should_close = 0;



// easy macros for error handling
static inline void check_error_OOM(int cond, int line) {
	if(cond == 1) {
		fprintf(stderr, "ERROR: Out of memory! %d\n", line);
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
static char* strsplit(const char* str1, const char lookout, size_t len, size_t max) {
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



// prints out anything left on the stack in a verbose way
int stack_dump(lua_State *L) {
	int i = lua_gettop(L);
	printf("--------------- Stack Dump ----------------\n");
	while(i) {
		int t = lua_type(L, i); // get type number
		switch (t) { // switch type number
		case LUA_TSTRING:
			fprintf(stdout, "%d:(String):`%s`\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			fprintf(stdout, "%d:(Boolean):`%s`\n", i, lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			fprintf(stdout, "%d:(Number):`%g`\n", i, lua_tonumber(L, i));
			break;
		case LUA_TFUNCTION:
			fprintf(stdout, "%d:(Function):`@0x%p`\n", i, lua_topointer(L, i));
			break;
		case LUA_TTABLE:
			fprintf(stdout, "%d:(Table):`@0x%p`\n", i, lua_topointer(L, i));
			break;
		case LUA_TUSERDATA:
			fprintf(stdout, "%d:(Userdata):`@0x%p`\n", i, lua_topointer(L, i));
			break;
		case LUA_TLIGHTUSERDATA:
			fprintf(stdout, "%d:(LUserdata):`0x@%p`\n", i, lua_topointer(L, i));
			break;
		case LUA_TTHREAD:
			fprintf(stdout, "%d:(Thread):`0x%p`\n", i, lua_topointer(L, i));
			break;
		case LUA_TNONE:
			fprintf(stdout, "%d:(None)\n", i);
			break;
		default:
			fprintf(stdout, "%d:(Object):%s:`0x@%p`\n", i, lua_typename(L, t), lua_topointer(L, i));
			break;
		}
		i--;
	}
	printf("----------- Stack Dump Finished -----------\n");
	return 0;
}


// internal enums, represent lua error category
typedef enum LuaConsoleError {
	INTERNAL_ERROR = 0,
	SYNTAX_ERROR = 1,
	RUNTIME_ERROR = 2,
} LuaConsoleError;

// handles non-string errors
// if error message is not a string, execute a tostring on metatable if present
static inline const char* error_test_meta(const char** out_type) {
	const char* msg = lua_tostring(L, -1); // attempt tostring
	if(msg == NULL) { // if failed
		int meta = luaL_callmeta(L, -1, "__tostring"); // call the metatable __tostring
		int ret = lua_type(L, -1); 
		if(meta != 0) {
			#if DO_EXT_ERROR_RETS == 1
				if(ret == LUA_TSTRING || (ret == LUA_TNUMBER || ret == LUA_TBOOLEAN)
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

// handles out-of-lua error messages
// leaves 1 item on stack:
//		1. error message
static void print_error(LuaConsoleError error, int offset) {
	switch(error) {
	case INTERNAL_ERROR:
		fprintf(stderr, " (Internal)");
		break;
	case SYNTAX_ERROR:
		fprintf(stderr, " (Syntax)");
		break;
	case RUNTIME_ERROR:
		fprintf(stderr, " (Runtime)");
		break;
	}
	const char* type = "";
	const char* msg = error_test_meta(&type);
	size_t top = lua_gettop(L);
	fprintf(stderr, " | Stack Top: %zu | %s%s\n", top - offset, msg, type);
	#if DO_VERBOSE_ERRORS > 0
		if(top - offset > 1)
			stack_dump(L);
	#endif
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
	fprintf(stderr, " (Runtime) | Stack Top: %zu | %s%s\n", top, msg, type);
	#if DO_VERBOSE_ERRORS > 0
		fprintf(stderr, "%s\n", tb);
		#if DO_VERBOSE_ERRORS > 1
			if(top > 1)
				stack_dump(L);
		#endif
	#endif
	return 1;
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
				return luaL_error(L, "Interrupted!");
			if(i == PRIMARY_REPL_BUFFER_SIZE - 1) { // if max input reached
				fputs("Input line is too long!\n", stdout);
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
			size_t top = lua_gettop(L);
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
			if((status = lua_pcall(L, 0, LUA_MULTRET, base)) != 0) {
				lua_pop(L, 2); // err msg, err handler, also ignore it - no relevance
			} else {
				// code can't be `return %s;`'d and it doesn't syntax out, but it still works
				// by design, it always returns even nil so idk if this is even possible
				// in practice, I can't figure out how to trigger this else clause, so undefined behavior?
				fprintf(stderr, "Please submit a github issue with this command attached.");
			}
		}
	}
	
	return 0;
}



// append parameters to the stack for a (p)call to consume
static inline void inject_parameters() {
	for(size_t i=0; i<ARGS.parameters; i++)
		lua_pushlstring(L, ARGS.parameters_argv[i], strlen(ARGS.parameters_argv[i]));
}

// load parameters into global arg table
static inline void load_parameters() {
	lua_createtable(L, 0, ARGS.parameters);
	for(size_t i=0; i<ARGS.parameters; i++) {
		lua_pushinteger(L, i+1);
		lua_pushlstring(L, ARGS.parameters_argv[i], strlen(ARGS.parameters_argv[i]));
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");
}


// handle execution of REPL
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

// handle execution of strings
static int start_protective_mode_string(const char* str, size_t params) {
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
	if((status = lua_pcall(L, params, LUA_MULTRET, base)) != 0) {
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

// handle execution of files
static int start_protective_mode_file(const char* file, size_t params) {
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
	if((status = lua_pcall(L, params, 0, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}

// handle execution of anything to be required
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
	char* str = (char*) data + 2; // gather argument, ignore -D/-d
	
	char* m_args = strsplit(str, '=', strlen(str) + 1, 2); // split argument between '=', max is two (left and right)
	check_error(m_args == NULL, "Error: Incorrect -D specified. Use format 'name=value'.");
	
	char* arg1 = m_args; // left arg of '='
	char* arg2 = strnxt(arg1); // right arg of '='
	
	size_t dot_count = strcnt(arg1, '.'); // count subtable tranversions
	if(dot_count == 0) { // if its just a set global
		lua_pushlstring(L, arg2, strlen(arg2));
		lua_setglobal(L, arg1);
	} else if(dot_count > 0) { // if there are subtables
		char* tabs = strsplit(arg1, '.', strlen(arg1) + 1, -1);
		check_error(tabs == NULL, "Error: Parsing -D specified. Use format 'subtab.name=value'.");
		
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
		lua_pop(L, dot_count-1); // everything but root table
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
				fprintf(stderr, "%s%s%s\n", "Error: ", name, " could not be required because no `require()`.");
			return;
		}
	}
	start_protective_mode_file(name, (ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
	free(str1);
}



// handles arguments, cwd, loads necessary data, executes lua
int main(int argc, char* argv[])
{
	// handle arguments
	if(argc == 1) { // post-exist if !(arguments > 1)
		ARGS.post_exist = 1;
		ARGS.no_file = 1;
	} else {
		if(argv[1][0] == '-' || argv[1][0] == '/') { // don't try to execute file if it isn't first argument
			ARGS.no_file = 1;
		} else {
			// i<argc might not run final file?
			for(ARGS.file_count=0; ARGS.file_count+1<(size_t)argc && (argv[1+ARGS.file_count][0] != '-' && argv[1+ARGS.file_count][0] != '/'); ARGS.file_count++);
		}
		for(size_t i=1; i<(size_t)argc; i++) {
			if(ARGS.parameters_argv != NULL) // if we have args around, break
				break;
			switch(argv[i][0]) { // skip over non-switches
			case '/':
			case '-':
				break;
			default:
				continue;
			}
			if(strlen(argv[i]) == 6) // a way of handling `--help` for common unix
				if(memcmp(argv[i], "--help", 6) == 0)
					argv[i][1] = '?';
			switch(argv[i][1]) { // set variables up for later parsing
			case 'v': case 'V':
				ARGS.print_version = 1;
				break;
			case 'R':
				ARGS.no_env_var = 1;
				break;
			case 'r':
				ARGS.no_libraries = 1;
				break;
			case 's': case 'S':
				ARGS.start = argv[i+1];
				break;
			case 'p': case 'P':
				ARGS.post_exist = 1;
				break;
			case 'c': case 'C':
				ARGS.copyright_squelch = 1;
				break;
			case 'd': case 'D':
				if(ARGS.globals == NULL)
					ARGS.globals = array_new(DEFINES_INIT, DEFINES_EXPANSION, sizeof(char*));
				check_error_OOM(ARGS.globals == NULL, __LINE__);
				array_push(ARGS.globals, argv[i]);
				break;
			case 'l': case 'L':
				if(ARGS.libraries == NULL)
					ARGS.libraries = array_new(LIBRARIES_INIT, LIBRARIES_EXPANSION, sizeof(char*));
				check_error_OOM(ARGS.libraries == NULL, __LINE__);
				if(argv[i][2] == 0)
					array_push(ARGS.libraries, argv[i+1]);
				else array_push(ARGS.libraries, argv[i]+2);
				break;
			case 't': case 'T':
				for(size_t j=0; j<strlen(argv[i]) - 2; j++) {
					switch(argv[i][2+j]){
						case 'a': case 'A':
							ARGS.delay_parameters = 1;
							break;
						case 'b': case 'B':
							ARGS.no_tuple_parameters = 1;
							break;
					}
				}
				break;
			case 'n': case 'N':
				ARGS.parameters = (argc - i) - 1;
				ARGS.parameters_argv = &(argv[i+1]);
				break;
			case 'E':
				ARGS.run_after_libs = 1;
				if(argv[i][2] == 0)
					ARGS.run_str = argv[i + 1];
				else ARGS.run_str = argv[i]+2;
				break;
			case 'e':
				ARGS.run_after_libs = 0;
				if(argv[i][2] == 0)
					ARGS.run_str = argv[i + 1];
				else ARGS.run_str = argv[i]+2;
				break;
			case '\0':
				ARGS.do_stdin = 1;
				break;
			case '-':
				i = argc;
				break;
			#if defined(LUA_JIT_51)
				case 'j':
					if(ARGS.luajit_jcmds == NULL)
						ARGS.luajit_jcmds = array_new(DEFINES_INIT, DEFINES_EXPANSION, sizeof(const char*));
					check_error_OOM(ARGS.luajit_jcmds == NULL, __LINE__);
					
					char* jcmd = argv[i] + 2;
					if(*jcmd == ' ' || *jcmd == '\0') {
						if(i + 1 >= argc) {
							fputs("LuaJIT Warning: malformed argument `-j` has no parameter!\n", stderr);
							break;
						} else
							jcmd = argv[i+1];
					}
					array_push(ARGS.luajit_jcmds, jcmd);
					break;
				case 'O':
					if(ARGS.luajit_opts == NULL)
						ARGS.luajit_opts = array_new(DEFINES_INIT, DEFINES_EXPANSION, sizeof(const char*));
					check_error_OOM(ARGS.luajit_opts == NULL, __LINE__);
					if(strlen(argv[i]) > 2)
						array_push(ARGS.luajit_opts, argv[i] + 2);
					else fputs("LuaJIT Warning: malformed argument `-O` has no parameter!\n", stderr);
					break;
				case 'b':
					if(i + 1 < argc)
						ARGS.luajit_bc = argv + i;
					else
						fputs("LuaJIT Warning: malformed argument `-b` has no parameter!\n", stderr);
					break;
			#endif
			case '?':
				fputs(HELP_MESSAGE, stdout);
				return EXIT_SUCCESS;
			default:
				fprintf(stdout, "Error: Argument `%s` not recognized!\n", argv[i]);
				return EXIT_FAILURE;
			}
		}
	}
	
	// initiate lua
	L = luaL_newstate();
	check_error_OOM(L == NULL, __LINE__);
	
	#if defined(LUA_JIT_51)
		LUAJIT_VERSION_SYM();
	#endif
	
	
	
	// initiate the libraries
	if(ARGS.no_libraries == 0) {
		lua_gc(L, LUA_GCSTOP, 0);
		luaL_openlibs(L);
		lua_gc(L, LUA_GCRESTART, -1);
	}
	
	
	
	// handle init environment variable
	if(ARGS.no_env_var == 0) {
		const char* env_init = getenv(ENV_VAR);
		if(env_init != NULL) {
			if(env_init[0] == '@')
				start_protective_mode_file(env_init + 1, 0);
			else start_protective_mode_string(env_init, 0);
		}
	} else {
		lua_pushboolean(L, 1);
		lua_setfield(L, LUA_REGISTRYINDEX, "LUA_NOENV");
	}
	
	
	
	// copyright
	if(ARGS.copyright_squelch == 0) {
		fputs(LUA_VERSION " " LUA_COPYRIGHT "\n", stdout);
		fputs(LUA_CONSOLE_COPYRIGHT "\n", stdout);
		#if defined(LUA_JIT_51)
			fputs("LuaJIT " LUAJIT_COPYRIGHT "\n", stdout);
		#endif
		fputs("\n", stdout);
	}
	
	
	#if defined(LUA_JIT_51)
		if(ARGS.no_libraries == 0) {
			int status = jitargs(L, ARGS.luajit_jcmds, ARGS.luajit_opts, ARGS.luajit_bc, ARGS.copyright_squelch);
			if(ARGS.luajit_bc != NULL)
				return status;
		}
	#endif
	
	
	// print out the version, new state because no_libraries can be 1
	if(ARGS.print_version == 1) {
		lua_State* gL = NULL;
		if(ARGS.no_libraries == 1) {
			gL = luaL_newstate();
			check_error_OOM(gL == NULL, __LINE__);
			luaL_openlibs(gL);
		} else {
			gL = L;
		}
		
		// print lua version
		lua_getglobal(gL, "_VERSION");
		fprintf(stdout, "%s\n", lua_tostring(gL, 1));
		lua_pop(L, 1); // lua version
		if(ARGS.no_libraries == 1)
			lua_close(gL);
	}
	
	
	// query the ability to post-exist
	if(!IS_ATTY) {
		#if defined(_WIN32) || defined(_WIN64)
			if(GetConsoleWindow() != 0 && (argc > 1 && ARGS.post_exist == 1))
				ARGS.restore_console = 1;
			else
				ARGS.post_exist = 0;
		#else
			int fd = open("/dev/tty", O_WRONLY);
			if(fd != -1) {
				ARGS.restore_console = 1;
				close(fd);
			} else
				ARGS.post_exist = 0;
		#endif
	}
	
	// make sure to start in the requested directory, if any
	check_error(ARGS.start != NULL && chdir(ARGS.start) == -1, "Error: Invalid start directory supplied.");
	
	
	// initiate global variables set up
	if(ARGS.globals != NULL) {
		array_consume(ARGS.globals, load_globals);
		array_free(ARGS.globals);
	}
	
	
	// load parameters early
	if(ARGS.delay_parameters == 0)
		load_parameters();
	
	
	// run executable string before -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 0)
		start_protective_mode_string(ARGS.run_str, (ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
	
	
	// do passed libraries/modules
	if(ARGS.libraries != NULL) {
		array_consume(ARGS.libraries, load_libraries);
		array_free(ARGS.libraries);
	}
	
	
	// run executable string after -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 1)
		start_protective_mode_string(ARGS.run_str, (ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
	
	
	
	// if there is nothing to do, then exit, as there is nothing left to do
	//   if applicable,
	//   - load parameters late
	//   - load function into protected mode (pcall)
	//   - post-exist
	int status = 0;
	if(ARGS.delay_parameters == 1)
		load_parameters();
	
	if(ARGS.no_file == 0) {
		for(size_t i=0; i<ARGS.file_count; i++) {
			status = start_protective_mode_file(argv[i+1], (ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
			if(status != 0) {
				fprintf(stderr, "LuaConsole ended on file `%s`!\n", argv[1+i]);
				goto exit;
			}
		}
	}
	
	// stdin
	if(ARGS.do_stdin == 1) {
		status = start_protective_mode_file(0, (ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
		if(status != 0) {
			fprintf(stderr, "LuaConsole had an error in stdin!\n!");
			goto exit;
		}
	}
	
	// post-exist
	if(ARGS.post_exist == 1) {
		if(ARGS.restore_console == 1) {
			#if defined(_WIN32) || defined(_WIN64)
				HANDLE hand_stdin = CreateFile("CONIN$", (GENERIC_READ | GENERIC_WRITE), FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0);
				int hand_stdin_final = _open_osfhandle((intptr_t)hand_stdin, _O_TEXT);
				_dup2(hand_stdin_final, fileno(stdin));
				SetStdHandle(STD_INPUT_HANDLE, (HANDLE) _get_osfhandle(fileno(stdin)));
				_close(hand_stdin_final);
			#else
				fclose(stdin);
				freopen("/dev/tty", "r", stdin);
			#endif
		}
		status = start_protective_mode_REPL();
	}
	
	
exit:
	// free resources
	lua_close(L);
	
	return status;
}

