/* MIT License
 * 
 * Copyright (c) 2017-2021 Cody Tilkins
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
#	if defined(_WIN32) || defined(_WIN64)
#		define DEFAULT_LUA			"lclua-5.3.5.dll"
#	else
#		define DEFAULT_LUA			"lclua-5.3.5.so"
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
#include <locale.h>

#if defined(_WIN32) || defined(_WIN64)
#	define WIN32_LEAN_AND_MEAN
#	include <windows.h>
#else
#	include <unistd.h>
#	include <dlfcn.h>
#endif

#include "luadriver.h"
#include "darr.h"
#include "lang.h"


// struct for args to be seen across functions
static LC_ARGS ARGS;
static LangCache* lang;

#define _(str) langfile_get(lang, str)


// easy macros for error handling
static inline void check_error_OOM(int cond, int line) {
	if(cond == 1) {
		fprintf(stderr, _("OOM"), line);
		exit(EXIT_FAILURE);
	}
}

static inline void check_error(int cond, const char* str) {
	if(cond == 1) {
		fprintf(stderr, str);
		exit(EXIT_FAILURE);
	}
}


int main(int argc, char** argv) {
	
	const char* language = 0;
	#if defined(_WIN32) || defined(_WIN64)
		const char english[] = "lang/english.txt";
		const char chinese[] = "lang/chinese.txt";
		const char russian[] = "lang/russian.txt";
		const char portuguese[] = "lang/portuguese.txt";
		const char spanish[] = "lang/spanish.txt";
		
		setlocale(LC_ALL, "");
		
		switch(GetUserDefaultUILanguage() | 0xFF) { // first byte is lang id
		case 0x09: // english
			language = "lang/english.txt";
			break;
		case 0x04: // chinese
			language = "lang/chinese.txt";
			break;
		case 0x11: // japanese
			language = "lang/japanese.txt";
			break;
		case 0x19: // russian
			language = "lang/russian.txt";
			break;
		case 0x16: // portuguese
			language = "lang/portuguese.txt";
			break;
		case 0x0A: // spanish
			language = "lang/spanish.txt";
			break;
		default: // needs translation >:(
			language = "lang/english.txt";
			break;
		}
	#else
		language = "lang/english.txt";
	#endif
	
	language = "lang/english.txt";
	
	// load language file
	lang = langfile_load(language);
	if(lang == 0) {
		puts("Failed to load lang file!");
		return EXIT_FAILURE;
	}
	
	// default vars
	ARGS.post_exist = 0;
	ARGS.no_file = 1;
	
	// handle post-exist
	// don't try to execute file if it isn't first argument
	// don't post-exist if files present, must explicitly ask for it
	if(argc < 2 || (argv[1][0] == '-' || argv[1][0] == '/')) {
		ARGS.post_exist = 1;
	} else {
		ARGS.no_file = 0;
		// count files
		ARGS.files_index = &(argv[1]);
		for(ARGS.file_count=0;
			ARGS.file_count + 1 < ((size_t) argc)
			&& (
				   argv[1 + ARGS.file_count][0] != '-'
				&& argv[1 + ARGS.file_count][0] != '/'
			);
			ARGS.file_count++
		);
	}
	
	// process switches
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
		case 'q': case 'Q':
			ARGS.copyright_squelch = 1;
			break;
		case 'd': case 'D':
			if(ARGS.globals == NULL)
				ARGS.globals = array_new(DEFINES_INIT, DEFINES_EXPANSION);
			check_error_OOM(ARGS.globals == NULL, __LINE__);
			array_push(ARGS.globals, argv[i][2] == 0 ? argv[i+1] : argv[i]+2);
			break;
		case 'l': case 'L':
			ARGS.post_exist = 0;
			if(ARGS.libraries == NULL)
				ARGS.libraries = array_new(LIBRARIES_INIT, LIBRARIES_EXPANSION);
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
		case 'c': case 'C':
			ARGS.post_exist = 0;
			ARGS.do_luac = 1;
			ARGS.luac_argc = argc - i;
			ARGS.luac_argv = &(argv[i]);
			i = argc;
			break;
		case '\0':
			ARGS.post_exist = 0;
			ARGS.do_stdin = 1;
			break;
		case '-':
			if(memcmp(argv[i], "--help", 6) == 0)
				ARGS.do_help = 1;
			i = argc;
			break;
		case 'j':
			ARGS.jitjcmd = argv;
			ARGS.jitjcmd_argc = i;
			break;
		case 'O':
			ARGS.jitocmd = argv;
			ARGS.jitocmd_argc = i;
			break;
		case 'b':
			ARGS.post_exist = 0;
			ARGS.jitbcmd = argv;
			ARGS.jitbcmd_argc = i;
			break;
		case '?':
			ARGS.do_help = 1;
			i = argc;
			break;
		default:
			fprintf(stdout, _("ERROR_INVALID_ARG"), argv[i]);
			return EXIT_FAILURE;
		}
	}
	
	// override if requested
	if(req_pe == 1)
		ARGS.post_exist = 1;
	
	luacon_loaddll _luacon_loaddll = (luacon_loaddll) 0;
	
	char luastr[260];
	if(ARGS.luaver != 0) {
		memset(luastr, 0, 260);
		strcat(luastr, "liblc");
		strcat(luastr, ARGS.luaver);
		#if defined(_WIN32) || defined(_WIN64)
			strcat(luastr, ".dll");
		#else
			strcat(luastr, ".so");
		#endif
	}
	
	#if defined(_WIN32) || defined(_WIN64)
		HMODULE luacxt;
		luacxt = LoadLibrary(ARGS.luaver == 0 ? DEFAULT_LUA : luastr);
		check_error(luacxt == 0, _("LC_DLL_MIA"));
		
		_luacon_loaddll = (luacon_loaddll) GetProcAddress(luacxt, "luacon_loaddll");
		check_error(_luacon_loaddll == 0, _("LC_DLL_NO_FUNC"));
	#else
		void* luacxt;
		luacxt = dlopen(ARGS.luaver == 0 ? DEFAULT_LUA : luastr, RTLD_NOW);
		check_error(luacxt == 0, dlerror());
		
		_luacon_loaddll = dlsym(luacxt, "luacon_loaddll");
		check_error(_luacon_loaddll == 0, dlerror());
	#endif
	
	int status = 0;
	status = _luacon_loaddll(ARGS, lang);
	
	// todo: clean arrays
	langfile_free(lang);
	array_free(ARGS.globals);
	array_free(ARGS.libraries);
	
	#if defined(_WIN32) || defined(_WIN64)
		FreeLibrary(luacxt);
	#else
		dlclose(luacxt);
	#endif
	
	return status;
}

