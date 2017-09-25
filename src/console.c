
/*
 * Lua.c Console
 * 
 *		- Line by Line interpretation
 *		- Files executed by passing
 *		- Working directory support
 *		- Built in stack-dump
 * Works with:
 *		Lua5.3.x, Lua5.2.x, Lua5.1.x
 * 
 * 5.2.x and 5.1.x assume that you have enough memory to start initial functions.
 * 
 */

// unsupported feature, defined to prepare for future
#define USE_ADDITIONS

#define PRIMARY_BUFFER_SIZE		(1024 + 1)
#define SECONDARY_BUFFER_SIZE	(1032 + 1)

#define DEFINES_INIT			4
#define DEFINES_EXPANSION		4

#if defined(linux) || defined(__linux__) || defined(__linux)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#elif defined(__APPLE__) || defined(__MACH__)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#elif defined(_WIN32) || defined(_WIN64)
#	include <windows.h>
#	include <stdio.h>
#	include <stdlib.h>
#	include <dirent.h>
#else
#	error "Not familiar. Set up headers accordingly, or -D__linux__ or -D__APPLE__ or -D_WIN32"
#endif

#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#if defined(USE_ADDITIONS)
#	include "additions.h"
#endif


#define LUA_CONSOLE_COPYRIGHT	"LuaConsole Copyright MIT (C) 2017 Hydroque\n"


// internal enums, represent lua error category
typedef enum LuaConsoleError {
	INTERNAL_ERROR = 0,
	SYNTAX_ERROR = 1,
	RUNTIME_ERROR = 2,
} LuaConsoleError;


// usage message
const char HELP_MESSAGE[] = 
	"Lua Console | Version: 6/13/2017\n"
	LUA_COPYRIGHT
	LUA_CONSOLE_COPYRIGHT
	"\n"
	"Supports Lua5.3, Lua5.2, Lua5.1\n"
	"5.2.x and 5.1.x assume that you have enough memory for initial functions.\n"
	"\n"
	"\t- Files executed by passing\n"
	"\t- Working directory support\n"
	"\t- Built in stack-dump\n"
	"\n"
	"Usage: lua.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-a] [-c] [-?] [-n]{parameter1 ...} \n"
	"\n"
	"-v \t Prints the Lua version in use\n"
	"-e \t Prevents lua core libraries from loading\n"
	"-s \t Issues a new root path\n"
	"-a \t Removes the additions\n"
	"-c \t No copyright on init\n"
	"-d \t Defines a global variable as value after '='\n"
	"-n \t Start of parameter section\n"
	"-? \t Displays this help message\n";



// one environment per process
static lua_State* L;


// necessary to put this outside of main, print doesn't work
static int no_libraries = 0;




// comprehensive error output
static void print_error(LuaConsoleError error) {
	const char* msg = lua_tostring(L, 1);
	switch(error) {
	case INTERNAL_ERROR:
		printf("(Internal)");
		break;
	case SYNTAX_ERROR:
		printf("(Syntax)");
		break;
	case RUNTIME_ERROR:
		printf("(Runtime)");
		break;
	}
	size_t top = lua_gettop(L);
	fprintf(stderr, " | Stack Top: %d | %s\n", lua_gettop(L), msg);
	if(top > 1) // other than error message
		stack_dump(L);
	lua_pop(L, 1);
}


// handles the execution of a file.lua
static int lua_main_dofile(lua_State* L) {
	const char* file = lua_tostring(L, 1);
	lua_pop(L, 1);
	if(luaL_loadfile(L, file) != 0) {
		print_error(SYNTAX_ERROR);
		return 0;
	}
	if(lua_pcall(L, 0, 0, 0) != 0) {
		print_error(RUNTIME_ERROR);
		return 0;
	}
	return 0;
}



// all-in-one function to handle file and line by line interpretation
int start_protective_mode(lua_CFunction func, const char* file, char** parameters_argv, size_t param_len) {
	lua_pushcclosure(L, func, 0); /* possible out of memory error in 5.2/5.1 */
	lua_pushlstring(L, file, strlen(file)); /* possible out of memory error in 5.2/5.1 */
	if(param_len != 0) { // load parameters in
		lua_createtable(L, param_len, 0);
		size_t i;
		for (i=0; i<param_len; i++) {
			lua_pushinteger(L, i+1);
			lua_pushlstring(L, parameters_argv[i], strlen(parameters_argv[i]));
			lua_settable(L, -3);
		}
		lua_setglobal(L, "args");
	}
	int status = lua_pcall(L, 1, 0, 0);
	if(status != 0) {
		print_error(INTERNAL_ERROR);
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}

// returns a malloc'd string with each split item being seperated by \0
char* strsplit(const char* str1, const char lookout, size_t len, size_t max) {
	char* cpy = malloc(len);
	memcpy(cpy, str1, len);
	
	for (size_t i=0; i<len-1; i++) {
		if(str1[i] == lookout) {
			cpy[i] = '\0';
			max--;
		}
		if(max == 0)
			break;
	}
	return cpy;
}

// handles arguments, cwd, loads necessary data, executes lua
int main(int argc, char* argv[])
{
	static int print_version = 0;
	static int change_start = 0;
	static int no_file = 0;
	static char* start = 0;
	static int no_additions = 0;
	static int copyright_squelch = 0;
	
	static size_t parameters = 0;
	static char** parameters_argv = 0;
	
	static size_t globals = 0;
	static size_t globals_argv_len = 0;
	static char** globals_argv = 0;
	
	// handle arguments
	if(argc == 1) { // post-exist if !(arguments > 1)
		no_file = 1;
	} else {
		// don't try to execute file if it isn't first argument
		if(argv[1][0] == '-')
			no_file = 1;
		size_t i;
		for (i=1; i<(size_t)argc; i++) {
			// if we have args around, break
			if(parameters_argv != 0)
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
				change_start = 1;
				start = argv[i+1];
				break;
			case 'a': case 'A':
				no_additions = 1;
				break;
			case 'c': case 'C':
				copyright_squelch = 1;
				break;
			case 'd': case 'D':
				if(globals_argv == 0) {
					globals_argv = malloc(DEFINES_INIT * sizeof(char*));
					if(globals_argv == 0) {
						fprintf(stderr, "%s\n", "[1] Out of memory");
						return EXIT_FAILURE;
					}
					globals_argv_len = DEFINES_INIT;
				}
				if(globals == globals_argv_len) {
					globals_argv_len += DEFINES_EXPANSION;
					globals_argv = realloc(globals_argv, (globals_argv_len + DEFINES_EXPANSION) * sizeof(char*));
					if(globals_argv == 0) {
						fprintf(stderr, "%s\n", "[1] Out of memory");
						return EXIT_FAILURE;
					}
				}
				globals_argv[globals] = argv[i];
				globals++;
				break;
			case 'n': case 'N':
				parameters = (argc - i) - 1;
				parameters_argv = &(argv[i+1]);
				break;
			case '?':
				fprintf(stdout, "%s\n", HELP_MESSAGE);
				return EXIT_SUCCESS;
			}
		}
	}
	
	
	// make sure to start in the requested directory, if any
	if(change_start == 1 && chdir(start) == -1) {
		fprintf(stderr, "%s\n", "Invalid start directory supplied");
		fprintf(stdout, "%s\n", HELP_MESSAGE);
		return EXIT_FAILURE;
	}
	
	
	// initiate lua
	L = luaL_newstate();
	if(L == 0) {
		fprintf(stderr, "%s\n", "Lua Allocation Failed: Out of Memory");
		return EXIT_FAILURE;
	}
	
	// initiate global variables set up
	if(globals != 0) {
		for (size_t i=0; i<globals; i++) {
			char* globals_D_offset = globals_argv[i] + 2;
			
			char* arg1 = strsplit(globals_D_offset, '=', strlen(globals_D_offset) + 1, 2);
			char* arg2 = arg1 + (strlen(arg1) + 1);
			
			lua_pushlstring(L, arg2, strlen(arg2));
			lua_setglobal(L, arg1);
			
			free(arg1);
		}
		free(globals_argv);
	}
	
	// initiate the libraries
	if(no_libraries == 0)
		luaL_openlibs(L);
	
	
	// print out the version, new state because no_libraries can be 1
	if(print_version == 1) {
		lua_State* gL = luaL_newstate();
		if(gL == 0) {
			fprintf(stderr, "%s\n", "Allocation Failed: Out of Memory");
			return EXIT_FAILURE;
		}
		
		luaL_openlibs(gL);
		
		// print lua version
		lua_getglobal(gL, "_VERSION");
		fprintf(stdout, "%s\n", lua_tostring(gL, 1));
		lua_pop(gL, 1);
		lua_close(gL);
	}
	
	// copyright
	if(copyright_squelch == 0) {
		fprintf(stdout, LUA_COPYRIGHT "\n");
		fprintf(stdout, LUA_CONSOLE_COPYRIGHT);
	}
	
	// if there is nothing to do, then exit, as there is nothing left to do
	if(no_file == 1) {
		lua_close(L);
		return EXIT_SUCCESS;
	}
	
	
	// add additions
	if(no_additions == 0)
		additions_add(L);
	
	// load function into protected mode (pcall)
	int status = start_protective_mode(&lua_main_dofile, argv[1], parameters_argv, parameters);
	
	
	// free resources
	lua_close(L);
	
	return status;
}

