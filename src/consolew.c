
#define PRIMARY_REPL_BUFFER_SIZE	(1024 + 1)
#define SECONDARY_REPL_BUFFER_SIZE	(1032 + 1)


#define DEFINES_INIT			4
#define DEFINES_EXPANSION		4

#define LIBRARIES_INIT			2
#define LIBRARIES_EXPANSION		2


#if defined(linux) || defined(__linux__) || defined(__linux)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define LUA_DLL_SO_NAME ".so"
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define LUA_DLL_SO_NAME ".so"
#elif defined(__APPLE__) || defined(__MACH__)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define LUA_DLL_SO_NAME ".so"
#elif defined(_WIN32) || defined(_WIN64)
#	include <windows.h>
#	include <stdio.h>
#	include <stdlib.h>
#	include <dirent.h>
#	define LUA_DLL_SO_NAME ".dll"
#else
#	error "OS not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#endif

#include <string.h>

#include "lua53/lua.h"
#include "lua53/lualib.h"
#include "lua53/lauxlib.h"

#include "darr.h"


#define LUA_CONSOLE_COPYRIGHT	"LuaConsole Copyright MIT (C) 2017 Hydroque\n"



// usage message
const char HELP_MESSAGE[] = 
	"Lua Console | Version: 1/6/2017\n"
	LUA_COPYRIGHT
	"\n"
	LUA_CONSOLE_COPYRIGHT
	"\n"
	"Supports Lua5.3, Lua5.2, Lua5.1\n"
	"\n"
	"\t- Files executed by passing\n"
	"\t- Global variable defintions\n"
	"\t- PUC-Lua and LuaJIT compatible\n"
	"\t- Dynamic module loading\n"
	"\t- Built-in stack-dump\n"
	"\t- Line by Line interpretation\n"
	"\n"
	"Usage: luaw.exe [FILE] [-v] [-e] [-s PATH] [-p] [-a] [-c] [-Dvar=val]\n"
	"\t[-Dtab.var=val] [-Lfile.lua] [-Llualib" LUA_DLL_SO_NAME "] [-b{a,b,c,d}] [-?]\n"
	"\t[-r \"string\"] [-R \"string\"] [-n {parameter1 ...}]\n"
	"\n"
	"-v \t\t Prints the Lua version in use\n"
	"-e \t\t Prevents lua core libraries from loading\n"
	"-s \t\t Issues a new root path\n"
	"-p \t\t Has console post exist after script in line by line mode\n"
	"-c \t\t No copyright on init\n"
	"-d \t\t Defines a global variable as value after '='\n"
	"-l \t\t Executes a module before specified script or post-exist\n"
	"-b[a,b,c,d] \t Loads parameters after -l's and -r\n"
	"-B[a,b,c,d] \t Loads parameters before -l's and -r\n"
		"\t\t\t[a]=arg-tuple for -l's, [b]=arg-tuple for file,\n"
		"\t\t\t[c]=no arg for file (only with -b), [d]=tuple for -r\n"
	"-r \t\t Executes a string as Lua Code BEFORE -l's\n"
	"-R \t\t Executes a string as Lua Code AFTER -l's\n"
	"-n \t\t Start of parameter section\n"
	"-? \t\t Displays this help message\n";



// one environment per process
static lua_State* L = NULL;


// necessary to put this outside of main, print doesn't work
static int no_libraries = 0;

// variable to end line by line interpretation loop, for adaption
static int should_close = 0;



// easy macro for error handling
static inline void check_error_OOM(int cond, int line) {
	if(cond == 1) {
		fprintf(stderr, "ERROR: Out of memory! %d\n", line);
		exit(EXIT_FAILURE);
	}
}

int stack_dump(lua_State *L) {
	int i = lua_gettop(L);
	printf("--------------- Stack Dump ----------------\n");
	while(i) {
		int t = lua_type(L, i);
		switch (t) {
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

// handles out-of-lua error messages
// returns 1 item:
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
	const char* msg = lua_tostring(L, -1);
	size_t top = lua_gettop(L);
	fprintf(stderr, " | Stack Top: %zu | %s\n", top - offset, msg);
	if(top - offset > 1)
		stack_dump(L);
}

// handles in-lua runtime error messages
// returns 1 item:
//		1. error message
static int lua_print_error(lua_State* L) {
	const char* msg = lua_tostring(L, -1);
	
	luaL_traceback(L, L, "--", 1);
	const char* tb = lua_tostring(L, -1);
	lua_pop(L, 1);
	
	size_t top = lua_gettop(L);
	fprintf(stderr, " (Runtime) | Stack Top: %zu | %s\n %s\n", top, msg, tb);
	if(top > 1)
		stack_dump(L);
	return 1;
}



// handles line by line interpretation
static int lua_main_postexist(lua_State* L) {
	char* input = malloc(PRIMARY_REPL_BUFFER_SIZE);
	char* retfmt = malloc(SECONDARY_REPL_BUFFER_SIZE);
	check_error_OOM(input == NULL || retfmt == NULL, __LINE__);
	
	int base = 0;
	int status = 0;
	while(should_close != 1) {
		// 1. reset
		status = 0;
		memset(input, 0, PRIMARY_REPL_BUFFER_SIZE);
		memset(retfmt, 0, SECONDARY_REPL_BUFFER_SIZE);
		
		// 2. read
		fputs(">", stdout);
		fgets(input, PRIMARY_REPL_BUFFER_SIZE - 1, stdin);
		input[strlen(input)-1] = '\0'; // remove \n
		snprintf(retfmt, SECONDARY_REPL_BUFFER_SIZE - 1, "return %s;", input);
		
		// 3. require %s; test
		status = luaL_loadstring(L, retfmt);
		if(status != 0) {
			lua_pop(L, 1); // err msg
		} else {
			// attempt first test, return seems to work
			size_t top = lua_gettop(L);
			status = lua_pcall(L, 0, LUA_MULTRET, 0);
			if(status == 0) { // on success
				top = lua_gettop(L) - top + 1; // + 1 = ignore pushed function
				if(top > 0) { // more than 0 arguments returned
					if(no_libraries == 1) {
						lua_pop(L, top); // remove arguments instead of pop with print
						continue;
					}
					lua_getglobal(L, "print");
					lua_insert(L, lua_gettop(L)-top);
					lua_call(L, top, 0);
				}
				continue;
			}
			lua_pop(L, 1); // err msg
		}
		
		lua_pushcclosure(L, lua_print_error, 0);
		// 4. load originally inserted code
		base = lua_gettop(L);
		if((status = luaL_loadstring(L, input)) != 0) {
			print_error(SYNTAX_ERROR, 1);
			lua_pop(L, 2); // err msg, err handler
		} else if((status = lua_pcall(L, 0, 0, base)) != 0) {
			// attempt originally inserted code
			lua_pop(L, 2); // err msg, err handler
		}
	}
	
	free(retfmt);
	free(input);
	return 0;
}



static inline void inject_parameters(char** parameters_argv, size_t param_len) {
	for(size_t i=0; i<param_len; i++)
		lua_pushlstring(L, parameters_argv[i], strlen(parameters_argv[i]));
}

// load parameters into global arg table
static inline void load_parameters(char** parameters_argv, size_t param_len) {
	lua_createtable(L, param_len, 0);
	for(size_t i=0; i<param_len; i++) {
		lua_pushinteger(L, i+1);
		lua_pushlstring(L, parameters_argv[i], strlen(parameters_argv[i]));
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");
}



// handle execution of files
static int start_protective_mode_string(const char* str, char** parameters_argv, size_t param_len) {
	lua_pushcclosure(L, lua_print_error, 0);
	int base = lua_gettop(L);
	int status = 0;
	if((status = luaL_loadbuffer(L, str, strlen(str), "execute")) != 0) {
		print_error(SYNTAX_ERROR, 1);
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	if(parameters_argv != NULL)
		inject_parameters(parameters_argv, param_len);
	if((status = lua_pcall(L, param_len, 0, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}

static int start_protective_mode_file(const char* file, char** parameters_argv, size_t param_len) {
	lua_pushcclosure(L, lua_print_error, 0);
	int base = lua_gettop(L);
	int status = 0;
	if((status = luaL_loadfile(L, file)) != 0) {
		print_error(SYNTAX_ERROR, 1);
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	if(parameters_argv != NULL)
		inject_parameters(parameters_argv, param_len);
	if((status = lua_pcall(L, param_len, 0, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}

static int start_protective_mode_require(const char* file) {
	lua_pushcclosure(L, lua_print_error, 0);
	int base = lua_gettop(L);
	lua_getglobal(L, "require");
	lua_pushlstring(L, file, strlen(file));
	int status = 0;
	if((status = lua_pcall(L, 1, 0, base)) != 0) {
		lua_pop(L, 2); // err msg, err handler
		return status;
	}
	lua_pop(L, 1); // err handler
	return status;
}

// handle execution of REPL
static inline int start_protective_mode_REPL() {
	lua_pushcclosure(L, lua_main_postexist, 0);
	int status = 0;
	if((status == lua_pcall(L, 0, 0, 0)) != 0) {
		print_error(INTERNAL_ERROR, 1);
		lua_pop(L, 1); // err msg
	}
	return status;
}



// returns a malloc'd string with each split item being separated by \0
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
static inline char* strnxt(const char* str1) {
	return (char*) str1 + (strlen(str1) + 1);
}

// counts the number of 'char c' occurances in a string
static inline size_t strcnt(const char* str1, char c) {
	size_t count = 0;
	while((*str1 == c && count++) || *str1++ != '\0');
	return count;
}



// handles arguments, cwd, loads necessary data, executes lua
int main(int argc, char* argv[])
{
	static int print_version = 0;
	static int post_exist = 0;
	static int no_file = 0;
	static char* start = NULL;
	static int copyright_squelch = 0;
	static int delay_parameters = 0;
	static int tuple_parameters = 0;
	static int core_tuple_parameters = 0;
	static int core_no_arg = 0;
	static int tuple_for_strexec = 0;
	
	static size_t parameters = 0;
	static char** parameters_argv = NULL;
	
	static Array* globals = NULL;
	
	static Array* libraries = NULL;
	
	static int run_after_libs = 0;
	static char* run_str = NULL;
	
	// handle arguments
	if(argc == 1) { // post-exist if !(arguments > 1)
		post_exist = 1;
		no_file = 1;
	} else {
		// don't try to execute file if it isn't first argument
		if(argv[1][0] == '-')
			no_file = 1;
		for(size_t i=1; i<(size_t)argc; i++) {
			// if we have args around, break
			if(parameters_argv != NULL)
				break;
			// don't parse non-switches
			switch(argv[i][0]) {
			case '/':
			case '-':
				break;
			default:
				continue;
			}
			// set variables up for later parsing
			switch(argv[i][1]) {
			case 'v': case 'V':
				print_version = 1;
				break;
			case 'e': case 'E':
				no_libraries = 1;
				break;
			case 's': case 'S':
				start = argv[i+1];
				break;
			case 'p': case 'P':
				post_exist = 1;
				break;
			case 'c': case 'C':
				copyright_squelch = 1;
				break;
			case 'd': case 'D':
				if(globals == NULL)
					globals = array_new(DEFINES_INIT, DEFINES_EXPANSION, sizeof(char*));
				check_error_OOM(globals == NULL, __LINE__);
				array_push(globals, argv[i]);
				break;
			case 'l': case 'L':
				if(libraries == NULL)
					libraries = array_new(LIBRARIES_INIT, LIBRARIES_EXPANSION, sizeof(char*));
				check_error_OOM(libraries == NULL, __LINE__);
				array_push(libraries, argv[i]);
				break;
			case 'B':
				delay_parameters = 1;
			case 'b':
				for(size_t j=0; j<strlen(argv[i]) - 2; j++) {
					switch(argv[i][2+j]){
						case 'a': case 'A':
							tuple_parameters = 1;
							break;
						case 'b': case 'B':
							core_tuple_parameters = 1;
							break;
						case 'c': case 'C':
							core_no_arg = 1;
							break;
						case 'd': case 'D':
							tuple_for_strexec = 1;
							break;
					}
				}
				break;
			case 'n': case 'N':
				parameters = (argc - i) - 1;
				parameters_argv = &(argv[i+1]);
				break;
			case 'R':
				run_after_libs = 1;
			case 'r':
				run_str = argv[i + 1];
				break;
			case '?':
				fputs(HELP_MESSAGE, stdout);
				return EXIT_SUCCESS;
			default:
				post_exist = 1;
				break;
			}
		}
	}
	
	// initiate lua
	L = luaL_newstate();
	check_error_OOM(L == NULL, __LINE__);
	
	// initiate the libraries
	if(no_libraries == 0)
		luaL_openlibs(L);
	else {
		lua_pushboolean(L, 1);
		lua_setfield(L, LUA_REGISTRYINDEX, "LUA_NOENV");
	}
	
	
	// copyright
	if(copyright_squelch == 0) {
		fputs(LUA_COPYRIGHT "\n", stdout);
		fputs(LUA_CONSOLE_COPYRIGHT, stdout);
	}
	
	
	// print out the version, new state because no_libraries can be 1
	if(print_version == 1) {
		lua_State* gL = NULL;
		if(no_libraries == 1) {
			gL = luaL_newstate();
			check_error_OOM(gL == NULL, __LINE__);
			luaL_openlibs(gL);
		} else {
			gL = L;
		}
		
		// print lua version
		lua_getglobal(gL, "_VERSION");
		fprintf(stdout, "%s\n", lua_tostring(gL, 1));
		if(no_libraries == 1)
			lua_close(gL);
	}
	
	
	// query the ability to post-exist
	if(!_isatty(_fileno(stdin)))
		post_exist = 0;
	
	
	// make sure to start in the requested directory, if any
	if(start != 0 && chdir(start) == -1) {
		fputs("Error: Invalid start directory supplied.", stderr);
		fputs(HELP_MESSAGE, stdout);
		return EXIT_FAILURE;
	}
	
	
	// initiate global variables set up
	if(globals != NULL) {
		for(size_t i=0; i<globals->size; i++) {
			char* str = (char*) array_get(globals, i) + 2;
			
			char* m_args = strsplit(str, '=', strlen(str) + 1, 2);
			if(m_args == 0) {
				fputs("Error: Incorrect -D specified. Use format 'name=value'.", stderr);
				return EXIT_FAILURE;
			}
			char* arg1 = m_args;
			char* arg2 = strnxt(arg1);
			
			size_t dot_count = strcnt(arg1, '.');
			if(dot_count > 0) {
				dot_count++;
				Array* args = array_new(dot_count, 4, sizeof(char*));
				check_error_OOM(args == NULL, __LINE__);
				
				char* d_args = strsplit(arg1, '.', strlen(arg1) + 1, -1);
				if(d_args == 0) {
					fputs("Error: Incorrect -D specified. Use format 'name.sub=value'.", stderr);
					return EXIT_FAILURE;
				}
				
				size_t offset = 0;
				for(size_t l=0; l<dot_count; l++) {
					array_push(args, d_args + offset);
					offset += strlen(d_args + offset) + 1;
				}
				
				lua_getglobal(L, (char*) array_get(args, 0));
				int istab = lua_istable(L, -1);
				if(istab == 0) {
					lua_pop(L, 1); // nil
					lua_newtable(L);
				}
				for(size_t l=1; l<dot_count - 1; l++) {
					char* argsl = (char*) array_get(args, l);
					lua_getfield(L, -1, argsl);
					if(lua_istable(L, -1) == 0) {
						lua_pop(L, 1); // nil
						lua_newtable(L);
						lua_setfield(L, -2, argsl);
						lua_getfield(L, -1, argsl);
					}
				}
				lua_pushlstring(L, arg2, strlen(arg2));
				lua_setfield(L, -2, (char*) array_get(args, dot_count - 1));
				lua_pop(L, dot_count-2); // root table
				if(istab == 0)
					lua_setglobal(L, (char*)array_get(args, 0));
				array_free(args);
				free(d_args);
				free(m_args);
				continue;
			}
			lua_pushlstring(L, arg2, strlen(arg2));
			lua_setglobal(L, arg1);
			
			free(m_args);
		}
		array_free(globals);
	}
	
	
	// load parameters early
	if(delay_parameters == 1)
		load_parameters(parameters_argv, parameters);
	
	
	// run executable string before -l's
	if(run_str != 0 && run_after_libs == 0) {
		start_protective_mode_string(run_str,
				(tuple_for_strexec == 1 ? parameters_argv : 0),
				(tuple_for_strexec == 1 ? parameters : 0));
	}
	
	
	// do passed libraries/modules
	if(libraries != NULL) {
		for(size_t i=0; i<libraries->size; i++) {
			char* name = (char*) array_get(libraries, i) + 2;
			char* str1 = strsplit(name, '.', strlen(name), 2);
			if(str1 != 0) {
				char* str2 = strnxt(str1);
				if((memcmp(str2, "dll", 3) == 0 || memcmp(str2, "so", 2) == 0)) {
					if(no_libraries == 0)
						start_protective_mode_require(str1);
					else
						fprintf(stderr, "%s%s%s\n", "Error: ", name, " could not be required because no libraries.");
					continue;
				}
			}
			start_protective_mode_file(name,
					(tuple_parameters == 1 ? parameters_argv : NULL),
					(tuple_parameters == 1 ? parameters : 0));
			free(str1);
		}
		array_free(libraries);
	}
	
	
	// run executable string after -l's
	if(run_str != 0 && run_after_libs == 1) {
		start_protective_mode_string(run_str,
				(tuple_for_strexec == 1 ? parameters_argv : 0),
				(tuple_for_strexec == 1 ? parameters : 0));
	}
	
	
	// if there is nothing to do, then exit, as there is nothing left to do
	//   - load parameters late, if applicable
	//   - load function into protected mode (pcall)
	//   - post-exist
	if(no_file == 0 || post_exist == 1) {
		if(delay_parameters == 0 && core_no_arg == 0)
			load_parameters(parameters_argv, parameters);
	}
	int status = 0;
	if(no_file == 0) {
		status = start_protective_mode_file(argv[1],
				(core_tuple_parameters == 1 ? parameters_argv : NULL),
				(core_tuple_parameters == 1 ? parameters : 0));
	}
	if(post_exist == 1)
		status = start_protective_mode_REPL();
	
	// free resources
	lua_close(L);
	
	return status;
}

