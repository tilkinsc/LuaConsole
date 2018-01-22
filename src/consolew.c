
// REPL line buffer length
#define PRIMARY_REPL_BUFFER_SIZE	(1024 + 1)
#define SECONDARY_REPL_BUFFER_SIZE	(PRIMARY_REPL_BUFFER_SIZE + 8) // + 8 is for `return ;`


// dynamic array initialization sizes for void*'s
#define DEFINES_INIT			(4)
#define DEFINES_EXPANSION		(4)

#define LIBRARIES_INIT			(2)
#define LIBRARIES_EXPANSION		(2)

#define ENV_VAR					"LUA_INIT"


// standard libraries per OS
#if defined(linux) || defined(__linux__) || defined(__linux)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME ""
#	define LUA_DLL_SO_NAME ".so"
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME ""
#	define LUA_DLL_SO_NAME ".so"
#elif defined(__APPLE__) || defined(__MACH__)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define IS_ATTY isatty(fileno(stdin))
#	define LUA_BIN_EXT_NAME ""
#	define LUA_DLL_SO_NAME ".so"
#elif defined(_WIN32) || defined(_WIN64)
#	include <windows.h>
#	include <stdio.h>
#	include <stdlib.h>
#	include <dirent.h>
#	define IS_ATTY _isatty(_fileno(stdin))
#	define LUA_BIN_EXT_NAME ".exe"
#	define LUA_DLL_SO_NAME ".dll"
#else
#	error "OS not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#endif


#include <string.h>
#include <signal.h>


#if defined(LUA_53)
#	include "lua53/lua.h"
#	include "lua53/lualib.h"
#	include "lua53/lauxlib.h"
#elif defined(LUA_52)
#	include "lua52/lua.h"
#	include "lua52/lualib.h"
#	include "lua52/lauxlib.h"
#elif defined(LUA_51)
#	include "lua51/lua.h"
#	include "lua51/lualib.h"
#	include "lua51/lauxlib.h"
#elif defined(LUA_JIT_51)
#	include "luajit51/lua.h"
#	include "luajit51/lualib.h"
#	include "luajit51/lauxlib.h"
#	include "luajit51/luajit.h"
#else
#	warning "Please place the Lua version needed in './include' 'lua53/*' 'lua52/*' 'lua51/*' 'luajit51/*'"
#	error "Define the version you want to use with -D. '-DLUA_53' '-DLUA_52' '-DLUA_51' '-DLUA_JIT_51'"
#endif


// inner-project includes
#include "darr.h"



// copyright information
#define LUA_CONSOLE_COPYRIGHT	"LuaConsole Copyright (C) 2017-2018, Hydroque"



// usage message
const char HELP_MESSAGE[] =
	"LuaConsole | Version: 1/20/2018\n\n"
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
	"Usage: luaw" LUA_BIN_EXT_NAME " [FILE] [-v] [-e] [-E] [-s PATH] [-p] [-c] [-Dvar=val]\n"
	"\t[-Dtb.var=val] [-Lfile.lua] [-Llualib" LUA_DLL_SO_NAME "] [-t{a,b,c,d}] [-T{a,b,c,d}]\n"
	"\t[-r \"string\"] [-R \"string\"] "
		#if defined(LUA_JIT_51)
			"[-j{cmd,cmd=arg},...]\n\t[-O{level,+flag,-flag,cmd=arg}] [-b{l,s,g,n,t,a,o,e,-} {IN,OUT}]\n\t"
		#endif
		"[-?] [-n {arg1 ...}]\n"
	"\n"
	"-v \t\tPrints the Lua version in use\n"
	"-e \t\tPrevents lua core libraries from loading\n"
	"-E \t\tPrevents lua environment variables from loading\n"
	"-s \t\tIssues a new current directory\n"
	"-p \t\tActivates REPL mode after all or no supplied scripts\n"
	"-c \t\tNo copyright on init\n"
	"-d \t\tDefines a global variable as value after '='\n"
	"-l \t\tExecutes a module before specified script or post-exist\n"
	"-t[a,b,c,d] \tLoads parameters after -l's and -r\n"
	"-T[a,b,d] \tLoads parameters before -l's and -r\n"
		"\t\t\t[a]=arg-tuple for -l's, [b]=arg-tuple for file,\n"
		"\t\t\t[c]=no arg for file, [d]=tuple for -r\n"
	"-r \t\tExecutes a string as Lua Code BEFORE -l's\n"
	"-R \t\tExecutes a string as Lua Code AFTER -l's\n"
	#if defined(LUA_JIT_51)
		"-j \t\t LuaJIT  Performs a control command loads an extension module\n"
		"-O \t\t LuaJIT  Sets an optimization level/parameters\n"
		"-b \t\t LuaJIT  Saves or lists bytecode\n"
	#endif
	"-? --help \tDisplays this help message\n"
	"-n \t\tStart of parameter section\n";



// LuaJIT functions slightly modified for LuaConsole
#if defined(LUA_JIT_51)
	// Load add-on module
	static int loadjitmodule(lua_State* L) {
		lua_getglobal(L, "require");
		lua_pushliteral(L, "jit.");
		lua_pushvalue(L, -3);
		lua_concat(L, 2);
		if (lua_pcall(L, 1, 1, 0)) {
			const char *msg = lua_tostring(L, -1);
			if (msg && !strncmp(msg, "module ", 7))
				goto nomodule;
			msg = lua_tostring(L, -1);
			if(msg == NULL) msg = "(error object is not a string)";
			fprintf(stderr, "LuaJIT Error: %s\n", msg);
			lua_pop(L, 1);
			return 1;
		}
		lua_getfield(L, -1, "start");
		if (lua_isnil(L, -1)) {
	nomodule:
			fputs("LuaJIT Error: unknown luaJIT command or jit.* modules not installed\n", stderr);
			return 1;
		}
		lua_remove(L, -2); // Drop module table
		return 0;
	}
	
	// Run command with options
	static int runcmdopt(lua_State* L, const char* opt) {
		int narg = 0;
		if (opt && *opt) {
			for (;;) { // Split arguments
				const char *p = strchr(opt, ',');
				narg++;
				if (!p) break;
				if (p == opt)
					lua_pushnil(L);
				else
					lua_pushlstring(L, opt, (size_t)(p - opt));
				opt = p + 1;
			}
			if (*opt)
				lua_pushstring(L, opt);
			else
				lua_pushnil(L);
		}
		int status = 0;
		if((status = lua_pcall(L, narg, 0, 0)) != 0) {
			const char* msg = lua_tostring(L, -1);
			if(msg == NULL) msg = "(error object is not a string)";
			fprintf(stderr, "LuaJIT Error: %s\n", msg);
			lua_pop(L, 1);
		}
		return status;
	}
	
	// JIT engine control command: try jit library first or load add-on module
	static int dojitcmd(lua_State* L, const char* cmd) {
		const char *opt = strchr(cmd, '=');
		lua_pushlstring(L, cmd, opt ? (size_t)(opt - cmd) : strlen(cmd));
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit"); // Get jit.* module table
		lua_remove(L, -2);
		lua_pushvalue(L, -2);
		lua_gettable(L, -2); // Lookup library function
		if (!lua_isfunction(L, -1)) {
			lua_pop(L, 2); // Drop non-function and jit.* table, keep module name
			if (loadjitmodule(L)) {
				return 1;
			}
		} else
			lua_remove(L, -2); // Drop jit.* table
		lua_remove(L, -2); // Drop module name
		return runcmdopt(L, opt ? opt+1 : opt);
	}
	
	// Optimization flags
	static int dojitopt(lua_State* L, const char* opt) {
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit.opt"); // Get jit.opt.* module table
		lua_remove(L, -2);
		lua_getfield(L, -1, "start");
		lua_remove(L, -2);
		return runcmdopt(L, opt);
	}
	
	// Save or list bytecode
	static int dobytecode(lua_State* L, char** argv) {
		int narg = 0;
		lua_pushliteral(L, "bcsave");
		if (loadjitmodule(L))
			return 1;
		if (argv[0][2]) {
			narg++;
			argv[0][1] = '-';
			lua_pushstring(L, argv[0]+1);
		}
		for (argv++; *argv != NULL; narg++, argv++)
			lua_pushstring(L, *argv);
		int status = 0;
		if((status = lua_pcall(L, narg, 0, 0)) != 0) {
			const char* msg = lua_tostring(L, -1);
			if(msg == NULL) msg = "(error object is not a string)";
			fprintf(stderr, "LuaJIT Error: %s\n", msg);
			lua_pop(L, 1);
		}
		return status;
	}
	
	// Prints JIT settings
	static void print_jit_status(lua_State* L) {
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit");
		lua_remove(L, -2);
		lua_getfield(L, -1, "status");
		lua_remove(L, -2); // _LOADED.jit.status
		int n = lua_gettop(L);
		lua_call(L, 0, LUA_MULTRET);
		fputs(lua_toboolean(L, n) ? "JIT: ON" : "JIT: OFF", stdout);
		const char* s = NULL;
		for (n++; (s = lua_tostring(L, n)); n++) {
			putc(' ', stdout);
			fputs(s, stdout);
		}
		putc('\n', stdout);
		lua_pop(L, lua_gettop(L) - n);
	}
#endif



// struct for args to be seen across functions
struct {
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
	size_t parameters;
	int print_version;
	int post_exist;
	int no_file;
	int copyright_squelch;
	int run_after_libs;
	int delay_parameters;
	int tuple_parameters;
	int core_tuple_parameters;
	int core_no_arg;
	int tuple_for_strexec;
	int no_env_var;
	int no_libraries;
} ARGS;

// flag for closing REPL
static int should_close = 0;

// buffers for REPL
static char* input = NULL;
static char* retfmt = NULL;

// one environment per process
static lua_State* L = NULL;



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
	const char* msg = lua_tostring(L, -1);
	size_t top = lua_gettop(L);
	fprintf(stderr, " | Stack Top: %zu | %s\n", top - offset, msg);
	if(top - offset > 1)
		stack_dump(L);
}

// handles in-lua runtime error messages
// returns/leaves 1 item on stack:
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
		while((ch = getchar()) != '\n') {
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
					lua_getglobal(L, "print");
					if(lua_isnil(L, -1) != 1) { // check even if no_libraries == 1
						lua_insert(L, lua_gettop(L)-top);
						lua_call(L, top, 0);
					} else
						lua_pop(L, 1 + top); // anything returned, global function print
				}
				continue;
			} else lua_pop(L, 1); // err msg, also ignore it - no relevance
		}
		
		// 4. load and execute originally inserted code with error handler
		lua_pushcclosure(L, lua_print_error, 0);
		base = lua_gettop(L);
		if((status = luaL_loadstring(L, input)) != 0) {
			print_error(SYNTAX_ERROR, 1);
			lua_pop(L, 2); // err msg, err handler
		} else if((status = lua_pcall(L, 0, 0, base)) != 0) {
			// attempt originally inserted code
			lua_pop(L, 2); // err msg, err handler
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
	
	int base = lua_gettop(L);
	int status = 0;
	if((status = luaL_loadbuffer(L, str, strlen(str), "execute")) != 0) {
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

// handle execution of files
static int start_protective_mode_file(const char* file, size_t params) {
	signal(SIGINT, SIG_IGN); // Ignore for now
	
	lua_pushcclosure(L, lua_print_error, 0);
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
static int start_protective_mode_require(const char* file) {
	signal(SIGINT, SIG_IGN); // Ignore for now
	
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
		
		lua_getglobal(L, tabs);
		int istab = lua_istable(L, -1);
		if(istab == 0) {
			lua_pop(L, 1); // nil
			lua_newtable(L);
		}
		
		char* cur_arg = tabs;
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
	char* name = (char*) data + 2;
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
	start_protective_mode_file(name, (ARGS.tuple_parameters == 1 ? ARGS.parameters : 0));
	free(str1);
}



// handles arguments, cwd, loads necessary data, executes lua
int main(int argc, char* argv[])
{
	// ensure all 0's
	memset(&ARGS, 0, sizeof(ARGS));
	
	// handle arguments
	if(argc == 1) { // post-exist if !(arguments > 1)
		ARGS.post_exist = 1;
		ARGS.no_file = 1;
	} else {
		// don't try to execute file if it isn't first argument
		if(argv[1][0] == '-' || argv[1][0] == '\\' || argv[1][0] == '/')
			ARGS.no_file = 1;
		for(size_t i=1; i<(size_t)argc; i++) {
			// if we have args around, break
			if(ARGS.parameters_argv != NULL)
				break;
			// skip over non-switches
			switch(argv[i][0]) {
			case '/':
			case '\\':
			case '-':
				break;
			default:
				continue;
			}
			// a way of handling `--help` for common unix
			if(strlen(argv[i]) == 6)
				if(memcmp(argv[i], "--help", 6) == 0)
					argv[i][1] = '?';
			// set variables up for later parsing
			switch(argv[i][1]) {
			case 'v': case 'V':
				ARGS.print_version = 1;
				break;
			case 'E':
				ARGS.no_env_var = 1;
				break;
			case 'e':
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
				array_push(ARGS.libraries, argv[i]);
				break;
			case 'T':
				ARGS.delay_parameters = 1;
			case 't':
				for(size_t j=0; j<strlen(argv[i]) - 2; j++) {
					switch(argv[i][2+j]){
						case 'a': case 'A':
							ARGS.tuple_parameters = 1;
							break;
						case 'b': case 'B':
							ARGS.core_tuple_parameters = 1;
							break;
						case 'c': case 'C':
							ARGS.core_no_arg = 1;
							break;
						case 'd': case 'D':
							ARGS.tuple_for_strexec = 1;
							break;
					}
				}
				break;
			case 'n': case 'N':
				ARGS.parameters = (argc - i) - 1;
				ARGS.parameters_argv = &(argv[i+1]);
				break;
			case 'R':
				ARGS.run_after_libs = 1;
				ARGS.run_str = argv[i + 1];
				break;
			case 'r':
				ARGS.run_after_libs = 0;
				ARGS.run_str = argv[i + 1];
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
						fputs("LuaJIT Warning: malfoirmed argument `-b` has no parameter!\n", stderr);
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
	// TODO: I wonder why in luajit.c `lua_State* L = lua_open();` is
	// defined inside `int main(int argc, char** argv)` and later
	// it is set to the proper variable. Seems redundant.
	L = luaL_newstate();
	check_error_OOM(L == NULL, __LINE__);
	
	#if defined(LUA_JIT_51)
		LUAJIT_VERSION_SYM();
	#endif
	
	
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
	
	
	
	// initiate the libraries
	if(ARGS.no_libraries == 0) {
		lua_gc(L, LUA_GCSTOP, 0);
		luaL_openlibs(L);
		lua_gc(L, LUA_GCRESTART, -1);
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
			if(ARGS.luajit_jcmds != NULL) {
				for(size_t i=0; i<ARGS.luajit_jcmds->size; i++)
					if(dojitcmd(L, (const char*) array_get(ARGS.luajit_jcmds, i)) != 0)
						fputs("LuaJIT Warning: Failed to execute control command or load extension module!\n", stderr);
				array_free(ARGS.luajit_jcmds);
			}
		
			if(ARGS.luajit_opts != NULL) {
				for(size_t i=0; i<ARGS.luajit_opts->size; i++)
					if(dojitopt(L, (const char*) array_get(ARGS.luajit_opts, i)) != 0)
						fputs("LuaJIT Warning: Failed to set with -O!\n", stderr);
				array_free(ARGS.luajit_opts);
			}
			
			if(ARGS.copyright_squelch == 0)
				print_jit_status(L);
			
			if(ARGS.luajit_bc != NULL)
				return dobytecode(L, ARGS.luajit_bc);
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
	if(!IS_ATTY)
		ARGS.post_exist = 0;
	
	
	// make sure to start in the requested directory, if any
	check_error(ARGS.start != NULL && chdir(ARGS.start) == -1, "Error: Invalid start directory supplied.");
	
	
	// initiate global variables set up
	if(ARGS.globals != NULL) {
		array_consume(ARGS.globals, load_globals);
		array_free(ARGS.globals);
	}
	
	
	// load parameters early
	if(ARGS.delay_parameters == 1)
		load_parameters();
	
	
	// run executable string before -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 0)
		start_protective_mode_string(ARGS.run_str, (ARGS.tuple_for_strexec == 1 ? ARGS.parameters : 0));
	
	
	// do passed libraries/modules
	if(ARGS.libraries != NULL) {
		array_consume(ARGS.libraries, load_libraries);
		array_free(ARGS.libraries);
	}
	
	
	// run executable string after -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 1)
		start_protective_mode_string(ARGS.run_str, (ARGS.tuple_for_strexec == 1 ? ARGS.parameters : 0));
	
	
	// if there is nothing to do, then exit, as there is nothing left to do
	//   - load parameters late, if applicable
	//   - load function into protected mode (pcall)
	//   - post-exist
	int status = 0;
	if(ARGS.no_file == 0 || ARGS.post_exist == 1) {
		if(ARGS.delay_parameters == 0 && ARGS.core_no_arg == 0)
			load_parameters();
		
		if(ARGS.no_file == 0)
			status = start_protective_mode_file(argv[1], (ARGS.core_tuple_parameters == 1 ? ARGS.parameters : 0));
		// TODO: what if status == 1
		if(ARGS.post_exist == 1)
			status = start_protective_mode_REPL();
	}
	
	// free resources
	lua_close(L);
	
	return status;
}

