
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
#	error "Not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#endif

#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#if defined(LUACON_ADDITIONS)
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
	"Lua Console | Version: 10/02/2017\n"
	LUA_COPYRIGHT
	"\n"
	LUA_CONSOLE_COPYRIGHT
	"\n"
	"Supports Lua5.3, Lua5.2, Lua5.1\n"
	"5.2.x and 5.1.x assume that you have enough memory for initial functions.\n"
	"\n"
	"\t- Line by Line interpretation\n"
	"\t- Files executed by passing\n"
	"\t- Global variable defintions\n"
	#if defined(LUACON_ADDITIONS)
		"\t- Working directory support\n"
		"\t- Built in stack-dump\n"
	#endif
	"\n"
	"Usage: lua.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-p] [-a] [-c] [-?] [-n]{parameter1 ...} \n"
	"\n"
	"-v \t Prints the Lua version in use\n"
	"-e \t Prevents lua core libraries from loading\n"
	"-s \t Issues a new root path\n"
	"-p \t Has console post exist after script in line by line mode\n"
	#if defined(LUACON_ADDITIONS)
		"-a \t Disables the additions\n"
	#endif
	"-c \t No copyright on init\n"
	"-d \t Defines a global variable as value after '='\n"
	"-n \t Start of parameter section\n"
	"-? \t Displays this help message\n";



// one environment per process
static lua_State* L;


// variable to end line by line iterpretation loop, for adaption
static int should_close = 0;

// necessary to put this outside of main, print doesn't work
static int no_libraries = 0;




// comprehensive error output
static void print_error(LuaConsoleError error) {
	const char* msg = lua_tostring(L, 1);
	switch(error) {
	case INTERNAL_ERROR:
		fprintf(stderr, "(Internal)");
		break;
	case SYNTAX_ERROR:
		fprintf(stderr, "(Syntax)");
		break;
	case RUNTIME_ERROR:
		fprintf(stderr, "(Runtime)");
		break;
	}
	size_t top = lua_gettop(L);
	fprintf(stderr, " | Stack Top: %zu | %s\n", top, msg);
	#if defined(LUACON_ADDITIONS)
		if(top > 1) // other than error message
			stack_dump(L);
	#endif
	lua_pop(L, 1);
}


// handles line by line interpretation
static int lua_main_postexist(lua_State* L) {
	char* buffer = malloc(PRIMARY_BUFFER_SIZE);
	if(buffer == 0) {
		fputs("Error: Out of memory.", stderr);
		exit(EXIT_FAILURE);
	}
	char* buffer2 = malloc(SECONDARY_BUFFER_SIZE);
	if(buffer2 == 0) {
		fputs("Error: Out of memory.", stderr);
		exit(EXIT_FAILURE);
	}
	
	int status = 0;
	while(should_close != 1) {
		// reset
		status = 0;
		memset(buffer, 0, PRIMARY_BUFFER_SIZE);
		memset(buffer2, 0, SECONDARY_BUFFER_SIZE);
		
		// read
		fputs(">", stdout);
		fgets(buffer, PRIMARY_BUFFER_SIZE - 1, stdin);
		buffer[strlen(buffer)-1] = '\0'; // remove \n
		snprintf(buffer2, SECONDARY_BUFFER_SIZE - 1, "return %s;", buffer);
		
		// load first test
		status = luaL_loadstring(L, buffer2);
		if(status != 0) {
			lua_pop(L, 1);
		} else {
			// attempt first test
			size_t top = lua_gettop(L);
			status = lua_pcall(L, 0, LUA_MULTRET, 0);
			if(status == 0) { // on success
				top = lua_gettop(L) - top + 1; // ignore function
				if(top > 0) { // more than 0 arguments returned
					if(no_libraries == 1) {
						lua_pop(L, top);
						continue;
					}
					lua_getglobal(L, "print");
					lua_insert(L, lua_gettop(L)-top);
					lua_call(L, top, 0);
				}
				continue;
			}
			lua_pop(L, 1);
		}
		
		// load originally inserted code
		status = luaL_loadstring(L, buffer);
		if(status != 0) {
			print_error(SYNTAX_ERROR);
			continue;
		}
		
		// attempt originally inserted code
		status = lua_pcall(L, 0, 0, 0);
		if(status != 0) {
			print_error(RUNTIME_ERROR);
		}
	}
	
	free(buffer);
	free(buffer2);
	
	return 0;
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
	int status = 0;
	if(file == 0)
		status = lua_pcall(L, 0, 0, 0);
	else {
		lua_pushlstring(L, file, strlen(file)); /* possible out of memory error in 5.2/5.1 */
		status = lua_pcall(L, 1, 0, 0);
	}
	if(status != 0) {
		print_error(INTERNAL_ERROR);
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}

// returns a malloc'd string with each split item being seperated by \0
char* strsplit(const char* str1, const char lookout, size_t len, size_t max) {
	char* cpy = malloc(len);
	if(cpy == 0) {
		fputs("Error: Out of memory.", stderr);
		return 0;
	}
	memcpy(cpy, str1, len);
	
	size_t temp_max = max;
	
	for (size_t i=0; i<len-1; i++) {
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
	return cpy;
}

// counts the number of 'char c' occurances in a string
size_t strcnt(const char* str1, char c) {
	size_t count = 0;
	while(*str1 != '\0') {
		count += (*str1 == c ? 1 : 0);
		str1++;
	}
	return count;
}

// handles arguments, cwd, loads necessary data, executes lua
int main(int argc, char* argv[])
{
	static int print_version = 0;
	static int change_start = 0;
	static int post_exist = 0;
	static int no_file = 0;
	static char* start = 0;
	#if defined(LUACON_ADDITIONS)
		static int no_additions = 0;
	#endif
	static int copyright_squelch = 0;
	
	static size_t parameters = 0;
	static char** parameters_argv = 0;
	
	static size_t globals = 0;
	static size_t globals_argv_len = 0;
	static char** globals_argv = 0;
	
	// handle arguments
	if(argc == 1) { // post-exist if !(arguments > 1)
		post_exist = 1;
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
			case 'p': case 'P':
				post_exist = 1;
				break;
			#if defined(LUACON_ADDITIONS)
				case 'a': case 'A':
					no_additions = 1;
					break;
			#endif
			case 'c': case 'C':
				copyright_squelch = 1;
				break;
			case 'd': case 'D':
				if(globals_argv == 0) { // reserve default space for globals
					globals_argv = malloc(DEFINES_INIT * sizeof(char*));
					if(globals_argv == 0) {
						fputs("Error: Out of memory.", stderr);
						return EXIT_FAILURE;
					}
					globals_argv_len = DEFINES_INIT;
				}
				if(globals == globals_argv_len) { // expand default space if needed
					globals_argv_len += DEFINES_EXPANSION;
					globals_argv = realloc(globals_argv, (globals_argv_len + DEFINES_EXPANSION) * sizeof(char*));
					if(globals_argv == 0) {
						fputs("Error: Out of memory.", stderr);
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
				fputs(HELP_MESSAGE, stdout);
				return EXIT_SUCCESS;
			}
		}
	}
	
	
	// make sure to start in the requested directory, if any
	if(change_start == 1 && chdir(start) == -1) {
		fputs("Error: Invalid start directory supplied.", stderr);
		fputs(HELP_MESSAGE, stdout);
		return EXIT_FAILURE;
	}
	
	
	// initiate lua
	L = luaL_newstate();
	if(L == 0) {
		fputs("Lua Allocation Error: Out of memory.", stderr);
		return EXIT_FAILURE;
	}
	
	
	// initiate global variables set up
	if(globals != 0) {
		for (size_t i=0; i<globals; i++) {
			char* globals_D_offset = globals_argv[i] + 2;
			
			char* m_args = strsplit(globals_D_offset, '=', strlen(globals_D_offset) + 1, 2);
			if(m_args == 0) {
				fputs("Error: Incorrect -D specified. Use format 'name=value'.", stderr);
				return EXIT_FAILURE;
			}
			char* arg1 = m_args;
			char* arg2 = arg1 + (strlen(arg1) + 1);
			
			// check for .'s to nest in table
			size_t dot_count = strcnt(arg1, '.');
			if(dot_count != 0) {
				dot_count++; // counts number of .'s, not splits
				char** args = malloc(dot_count * sizeof(char*));
				if(args == 0) {
					fputs("Error: Out of memory.", stderr);
					return EXIT_FAILURE;
				}
				
				char* d_args = strsplit(arg1, '.', strlen(arg1) + 1, -1);
				if(d_args == 0) {
					fputs("Error: Incorrect -D specified. Use format 'name.sub=value'.", stderr);
					return EXIT_FAILURE;
				}
				
				size_t offset = 0;
				for (size_t l=0; l<dot_count; l++) {
					args[l] = d_args + offset;
					offset += (strlen(args[l]) + 1);
				}
				
				lua_getglobal(L, args[0]);
				int istab = lua_istable(L, -1);
				if(istab == 0) {
					lua_pop(L, 1);
					lua_newtable(L);
				}
				for (size_t l=1; l<dot_count - 1; l++) {
					lua_getfield(L, -1, args[l]);
					if(lua_istable(L, -1) == 0) {
						lua_pop(L, 1);
						lua_newtable(L);
						lua_setfield(L, -2, args[l]);
						lua_getfield(L, -1, args[l]);
					}
				}
				lua_pushlstring(L, arg2, strlen(arg2));
				lua_setfield(L, -2, args[dot_count - 1]);
				lua_pop(L, dot_count-2);
				if(istab == 0)
					lua_setglobal(L, args[0]);
				
				free(d_args);
				free(args);
				free(m_args);
				continue;
			}
			
			lua_pushlstring(L, arg2, strlen(arg2));
			lua_setglobal(L, arg1);
			
			free(m_args);
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
			fputs("Error: Out of memory.", stderr);
			return EXIT_FAILURE;
		}
		
		luaL_openlibs(gL);
		
		// print lua version
		lua_getglobal(gL, "_VERSION");
		fputs(lua_tostring(gL, 1), stdout);
		lua_pop(gL, 1);
		lua_close(gL);
	}
	
	
	// copyright
	if(copyright_squelch == 0) {
		fputs(LUA_COPYRIGHT "\n", stdout);
		fputs(LUA_CONSOLE_COPYRIGHT, stdout);
	}
	
	
	// if there is nothing to do, then exit, as there is nothing left to do
	if(no_file == 1 && post_exist != 1) {
		lua_close(L);
		return EXIT_SUCCESS;
	}
	
	
	#if defined(LUACON_ADDITIONS)
		// add additions
		if(no_additions == 0)
			additions_add(L);
	#endif
	
	
	// load function into protected mode (pcall)
	int status = 0;
	if(post_exist == 1) {
		if(no_file == 0)
			status = start_protective_mode(&lua_main_dofile, argv[1], parameters_argv, parameters);
		status = start_protective_mode(&lua_main_postexist, NULL, parameters_argv, parameters);
	} else status = start_protective_mode(&lua_main_dofile, argv[1], parameters_argv, parameters);
	
	
	// free resources
	lua_close(L);
	
	return status;
}

