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

#if !defined(DEFAULT_LUA)
#	if defined(_WIN32) || defineD(_WIN64)
#		define DEFAULT_LUA			"lclua535.dll"
#	else
#		defined DEFAULT_LUA			"lclua535.so"
#	endif
#endif

// dynamic array initialization sizes for darr's
#define DEFINES_INIT				(4)
#define DEFINES_EXPANSION			(4)

#define LIBRARIES_INIT				(2)
#define LIBRARIES_EXPANSION			(2)


#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#	define WIN32_LEAN_AND_MEAN
#	include <windows.h>
#else
#	include <unistd.h>
#endif

#include "darr.h"
#include "luadriver.h"


// struct for args to be seen across functions
static LC_ARGS ARGS;


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


int main(int argc, char** argv) {
	
	// default vars
	ARGS.post_exist = 0;
	ARGS.no_file = 1;
	
	// handle arguments
	if(argc < 2 || (argv[1][0] == '-' || argv[1][0] == '/')) { // don't try to execute file if it isn't first argument
		ARGS.post_exist = 1;
	} else {
		// i<argc might not run final file?
		ARGS.no_file = 0;
		ARGS.files_index = &(argv[1]);
		for(ARGS.file_count=0; ARGS.file_count+1<(size_t)argc && (argv[1+ARGS.file_count][0] != '-' && argv[1+ARGS.file_count][0] != '/'); ARGS.file_count++);
	}
	int req_pe = 0;
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
		// TODO: convert to strcmp
		if(strlen(argv[i]) == 6) // a way of handling `--help` for common unix
			if(memcmp(argv[i], "--help", 6) == 0)
				argv[i][1] = '?';
		switch(argv[i][1]) { // set variables up for later parsing
		case 'w': case 'W':
			ARGS.luaver = (argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
			break;
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
			ARGS.start = (argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
			break;
		case 'p': case 'P':
			req_pe = 1;
			break;
		case 'c': case 'C':
			ARGS.copyright_squelch = 1;
			break;
		case 'd': case 'D':
			if(ARGS.globals == NULL)
				ARGS.globals = array_new(DEFINES_INIT, DEFINES_EXPANSION, sizeof(char*));
			check_error_OOM(ARGS.globals == NULL, __LINE__);
			array_push(ARGS.globals, argv[i]);
			// TODO: fix the fact you can't do `-D DEFINE` only `-DDEFINE`
			break;
		case 'l': case 'L':
			ARGS.post_exist = 0;
			if(ARGS.libraries == NULL)
				ARGS.libraries = array_new(LIBRARIES_INIT, LIBRARIES_EXPANSION, sizeof(char*));
			check_error_OOM(ARGS.libraries == NULL, __LINE__);
			array_push(ARGS.libraries, argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
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
			ARGS.post_exist = 0;
			ARGS.run_after_libs = 1;
			ARGS.run_str = (argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
			break;
		case 'e':
			ARGS.post_exist = 0;
			ARGS.run_after_libs = 0;
			ARGS.run_str = (argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
			break;
		case '\0':
			ARGS.post_exist = 0;
			ARGS.do_stdin = 1;
			break;
		case '-':
			i = argc;
			break;
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
		case '?':
			ARGS.do_help = 1;
			i = argc;
			break;
		default:
			fprintf(stdout, "Error: Argument `%s` not recognized!\n", argv[i]);
			return EXIT_FAILURE;
		}
	}
	
	// override if requested
	if(req_pe == 1)
		ARGS.post_exist = 1;
	
	luacon_loaddll* _luacon_loaddll = 0;
	
	char luastr[260];
	if(ARGS.luaver != 0) {
		memset(luastr, 0, 260);
		strcat(luastr, "lc");
		strcat(luastr, ARGS.luaver);
		#if defined(_WIN32) || defined(_WIN64)
			strcat(luastr, ".dll");
		#else
			strcat(luastr, ".so");
		#endif
	}
	
	#if defined(_WIN32) || defined(_WIN64)
		HMODULE luacxt;
		check_error((luacxt = LoadLibrary(ARGS.luaver == 0 ? DEFAULT_LUA : luastr)) == 0, "Could not find the LuaConsole library! (Default: " DEFAULT_LUA ")");
		_luacon_loaddll = (luacon_loaddll*) GetProcAddress(luacxt, "luacon_loaddll");
	#else
		void* luacxt;
		check_error((luacxt = dlopen(ARGS.luaver == 0 ? DEFAULT_LUA : luastr), RTLD_NOW) == 0, "Could not find the LuaConsole library! (Default: " DEFAULT_LUA ")");
		_luacon_loaddll = (luacon_loaddll*) dlsym(luacxt, "luacon_loaddll");
	#endif
	
	check_error(luacxt == 0, "Could not find the LuaConsole function `luacon_loaddll`!");
	int status = 0;
	status = _luacon_loaddll(ARGS);
	
	#if defined(_WIN32) || defined(_WIN64)
		FreeLibrary(luacxt);
	#else
		dlclose(luacxt);
	#endif
	
	return status;
}

