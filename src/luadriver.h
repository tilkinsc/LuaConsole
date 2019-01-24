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
// This is a template for DLLs to be built off, using consolew.h and ldata.h

#include "lang.h"
#include "darr.h"

typedef struct tag_LC_ARGS {
	size_t file_count;
	size_t parameters;
	char* luaver;
	char* start;
	char* run_str;
	Array* globals;
	Array* libraries;
	Array* luajit_jcmds;
	Array* luajit_opts;
	char** parameters_argv;
	char** luajit_bc;
	char** files_index;
	char** luac_argv;
	int luac_argc;
	int do_luac;
	int do_help;
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
} LC_ARGS;



#if defined(LC_LD_DLL)
#	if defined(_WIN32) || defined(_WIN64)
#		define LC_LD_API __declspec(dllexport)
#	else
#		define LC_LD_API extern __attribute__((visibility("default")))
#	endif
	
	LC_LD_API int luacon_loaddll(LC_ARGS _ARGS, LangCache* _lang);
	
#else
	
	typedef int (*luacon_loaddll)(LC_ARGS, LangCache*);
	
#endif


