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


// environment variable for lua usage
// TODO: I want to support LUA_INIT_5_2 LUA_INIT_5_1 and LUA_INIT_5_3 (ENV_VAR_EXT)
// 		which version takes precedence and falls back to LUA_INIT afterward
// #define ENV_VAR_EXT				(0)
#define ENV_VAR						"LUA_INIT"


#include <stdlib.h>
#include <stdio.h>

#if defined(_WIN32) || defined(_WIN64)
#	define WIN32_LEAN_AND_MEAN
#	include <windows.h>
#	include <direct.h>
#	define IS_ATTY					_isatty(_fileno(stdin))
#	define LUA_BIN_EXT_NAME 		".exe"
#	define LUA_DLL_SO_NAME 			".dll"
#else
#	include <unistd.h>
#	define IS_ATTY					isatty(fileno(stdin))
#	define _chdir					chdir
#	define LUA_BIN_EXT_NAME 		""
#	define LUA_DLL_SO_NAME 			".so"
#endif

#define _(str) langfile_get(lang, str)


#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#if defined(LUA_JIT_51)
#	include "jitsupport.h"
#endif

#include "darr.h"
#include "lang.h"
#include "luadriver.h"
#include "ldata.h"
#include "consolew.h"


const char HELP_MESSAGE[] =
	"LuaConsole | Version: 1/22/2019\n\n"
	#if LUA_VERSION_NUM <= 501
		LUA_VERSION " | " LUA_COPYRIGHT "\n"
	#else
		LUA_COPYRIGHT "\n"
	#endif
	LUA_CONSOLE_COPYRIGHT
	"\n"
	#if defined(LUA_JIT_51)
		LUAJIT_VERSION " " LUAJIT_COPYRIGHT " " LUAJIT_URL "\n"
	#endif
	"\nSupports Lua5.3, Lua5.2, Lua5.1, LuaJIT5.1\n"
	"\n"
	"Usage: luaw" LUA_BIN_EXT_NAME " [-c] [FILES] [-w] [-v] [-q] [-r] [-R] [-s PATH] [-p] [-Dvar=val]\n"
	"\t[-Dtb.var=val] [-Lfile.lua] [-Llualib" LUA_DLL_SO_NAME "] [-t{a,b}] [-e \"string\"]\n"
	"\t[-E \"string\"] [-] [--] "
		#if defined(LUA_JIT_51)
			"[-j{cmd,cmd=arg},...] [-O{level,+flag,-flag,cmd=arg}]\n\t[-b{l,s,g,n,t,a,o,e,-} {IN,OUT}] "
		#endif
		"[-?] [-n {arg1 ...}]\n"
	"\n"
	"-w \t\tWith Lua version x.x.x\n"
	"-v \t\tPrints the Lua version in use\n"
	"-q \t\tRemove copyright/luajit message\n"
	"-r \t\tPrevents lua core libraries from loading\n"
	"-R \t\tPrevents lua environment variables from loading\n"
	"-s \t\tIssues a new current directory\n"
	"-p \t\tActivates REPL mode after all or no supplied scripts\n"
	#if !defined(LUA_JIT_51)
		"-c \t\tWith the following arguments, interface to luac\n"
	#endif
	"-d \t\tDefines a global variable as value after '='\n"
	"-l \t\tExecutes a module before specified script or post-exist\n"
	"-t[a,b] \tLoads parameters after -l's and -e\n"
		"\t\t\t[a]=delay arg table for file. [b]=no tuples\n"
	"-e \t\tExecutes a string as Lua Code BEFORE -l's\n"
	"-E \t\tExecutes a string as Lua Code AFTER -l's\n"
	"-  \t\tProcesses input from stdin\n"
	"-- \t\tStops processing parameters\n"
	#if defined(LUA_JIT_51)
		"-j \t\t [LuaJIT] Performs a control command loads an extension module\n"
		"-O \t\t [LuaJIT] Sets an optimization level/parameters\n"
		"-b \t\t [LuaJIT] Saves or lists bytecode\n"
	#endif
	"-? --help \tDisplays this help message\n"
	"-n \t\tStart of parameter section\n";

// one environment per process
lua_State* L = NULL;



// TODO: This is a hack bc I didn't realize lua51 didn't have traceback
#if LUA_VERSION_NUM <= 501
	void luaL_traceback (lua_State *L, lua_State *L1, const char *msg, int level) {
		lua_pushlstring(L, " ", 1);
	}
#endif

#if !defined(LUA_JIT_51)
	extern int luac_main(int argc, char* argv[]);
#endif

// handles arguments, cwd, loads necessary data, executes lua
LC_LD_API int luacon_loaddll(LC_ARGS _ARGS, LangCache* _lang)
{
	ARGS = _ARGS; // global args for all
	lang = _lang;
	
	// print out help
	if(ARGS.do_help == 1) {
		fputs(HELP_MESSAGE, stdout);
		return EXIT_SUCCESS;
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
		#if defined(_MSC_VER)
			char* env_init;
			size_t len;
			errno_t err = _dupenv_s(&env_init, &len, ENV_VAR);
		#else
			char* env_init = getenv(ENV_VAR);
		#endif
		if(env_init != NULL) {
			if(env_init[0] == '@')
				start_protective_mode_file(env_init + 1, 0);
			else start_protective_mode_string(env_init, 0);
		}
		#if defined(_MSC_VER)
			free(env_init);
		#endif
	} else {
		lua_pushboolean(L, 1);
		lua_setfield(L, LUA_REGISTRYINDEX, "LUA_NOENV");
	}
	
	
	
	// copyright
	if(ARGS.copyright_squelch == 0 && ARGS.post_exist == 1) {
		#if LUA_VERSION_NUM <= 501
			fputs(LUA_VERSION " | " LUA_COPYRIGHT "\n", stdout);
		#else
			fputs(LUA_COPYRIGHT "\n", stdout);
		#endif
		fputs(LUA_CONSOLE_COPYRIGHT "\n", stdout);
		#if defined(LUA_JIT_51)
			fputs("LuaJIT " LUAJIT_COPYRIGHT "\n", stdout);
		#endif
		fputs("\n", stdout);
	}
	
	
	#if defined(LUA_JIT_51)
		if(ARGS.no_libraries == 0) {
			int status = jitargs(L,
				ARGS.luajit_jcmds, ARGS.luajit_opts, ARGS.luajit_bc,
				ARGS.copyright_squelch, ARGS.post_exist);
			
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
	
	
	int status = 0;
	
	#if !defined(LUA_JIT_51)
		// handle exclusively compilation
		if(ARGS.do_luac == 1) {
			luac_main(ARGS.luac_argc, ARGS.luac_argv);
			goto exit;
		}
	#endif
	
	
	// query the ability to post-exist
	if(!IS_ATTY) {
		#if defined(_WIN32) || defined(_WIN64)
			if(GetConsoleWindow() != 0 && ARGS.post_exist == 1)
				ARGS.restore_console = 1;
			else
				ARGS.post_exist = 0;
		#else
			int fd = open("/dev/tty", O_WRONLY);
			if(fd != -1 && ARGS.post_exist == 1) {
				ARGS.restore_console = 1;
				close(fd);
			} else
				ARGS.post_exist = 0;
		#endif
	}
	
	// make sure to start in the requested directory, if any
	check_error((ARGS.start != NULL && _chdir(ARGS.start) == -1), _("LDATA_BAD_SD"));
	
	
	// initiate global variables set up
	if(ARGS.globals != NULL) {
		array_consume(ARGS.globals, load_globals);
		array_free(ARGS.globals);
	}
	
	
	// load parameters early
	if(ARGS.delay_parameters == 0)
		load_parameters();
	
	// stdin
	if(ARGS.do_stdin == 1) {
		status = start_protective_mode_file(0,
			(ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
		if(status != 0) {
			fprintf(stderr, _("LDATA_BAD_STDIN"));
			goto exit;
		}
	}
	
	if(ARGS.restore_console == 1) {
		#if defined(_WIN32) || defined(_WIN64)
			HANDLE hand_stdin = CreateFile("CONIN$",
				(GENERIC_READ | GENERIC_WRITE), FILE_SHARE_READ,
				0, OPEN_EXISTING, 0, 0);
			int hand_stdin_final = _open_osfhandle((intptr_t)hand_stdin, _O_TEXT);
			_dup2(hand_stdin_final, _fileno(stdin));
			SetStdHandle(STD_INPUT_HANDLE, (HANDLE) _get_osfhandle(_fileno(stdin)));
			_close(hand_stdin_final);
		#else
			fclose(stdin);
			freopen("/dev/tty", "r", stdin);
		#endif
	}
	
	
	// run executable string before -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 0)
		start_protective_mode_string(ARGS.run_str,
			(ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
	
	
	// do passed libraries/modules
	if(ARGS.libraries != NULL) {
		array_consume(ARGS.libraries, load_libraries);
		array_free(ARGS.libraries);
	}
	
	
	// run executable string after -l's
	if(ARGS.run_str != 0 && ARGS.run_after_libs == 1)
		start_protective_mode_string(ARGS.run_str,
			(ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
	
	
	
	// if there is nothing to do, then exit, as there is nothing left to do
	//   if applicable,
	//   - load parameters late
	//   - load function into protected mode (pcall)
	//   - post-exist
	if(ARGS.delay_parameters == 1)
		load_parameters();
	
	// files
	if(ARGS.no_file == 0) {
		for(size_t i=0; i<ARGS.file_count; i++) {
			status = start_protective_mode_file(ARGS.files_index[i],
				(ARGS.no_tuple_parameters == 1 ? 0 : ARGS.parameters));
			if(status != 0) {
				fprintf(stderr, _("LDATA_END_FILE"), ARGS.files_index[i]);
				goto exit;
			}
		}
	}
	
	
	// post-exist
	if(ARGS.post_exist == 1)
		status = start_protective_mode_REPL();
	
	
exit:
	// free resources
	lua_close(L);
	
	return status;
}
