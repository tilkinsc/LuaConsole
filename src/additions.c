/* MIT License
 * 
 * Copyright (c) 2018 PoliteKiwi
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

#if defined(linux) || defined(__linux__) || defined(__linux)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define CLEAR_CONSOLE "clear"
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define CLEAR_CONSOLE "clear"
#elif defined(__APPLE__) || defined(__MACH__)
#	include <unistd.h>
#	include <stdio.h>
#	include <stdlib.h>
#	define CLEAR_CONSOLE "clear"
#elif defined(_WIN32) || defined(_WIN64)
#	include <windows.h>
#	include <stdio.h>
#	include <stdlib.h>
#	include <dirent.h>
#	define CLEAR_CONSOLE "cls"
#else
#	error "Not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#endif


#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>


// Please migrate your lua h's to a proper directory so versions don't collide
//   luajit make install puts them in /usr/local/include/luajit-X.X/*
//   lua51/52/53 puts them directly in /usr/local/include/* with version collision
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
#else
#	warning "Lua version not defined."
#	error "Define the version to use. '-DLUA_53' '-DLUA_52' '-DLUA_51' '-DLUA_JIT_51'"
#endif


#include "additions.h"



static int lua_cwd_getcwd(lua_State* L) {
	char buffer[PATH_MAX];
	lua_pushstring(L, getcwd(buffer, PATH_MAX));	
	return 1;
}

static int lua_cwd_setcwd(lua_State* L) {
	const char* path = lua_tostring(L, 1);
	lua_pop(L, 1);
	chdir(path);
	return 0;
}

static int lua_clear_window(lua_State* L) {
	system(CLEAR_CONSOLE);
	return 0;
}

// prints out anything left on the stack in a verbose way
static int stack_dump(lua_State *L) {
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

static int lua_fstat_time(lua_State* L) {
	const char* path = lua_tostring(L, 1);
	lua_pop(L, 1);
	static struct stat st;
	if(stat(path, &st) == -1)
		return 0;
	lua_pushnumber(L, st.st_mtime);
	return 1;
}



LUA_DLL_ENTRY luaopen_luaadd(lua_State* L) {
	
	// stack dump addition
	lua_pushcfunction(L, stack_dump);
	lua_setglobal(L, "stackdump");
	
	
	// io table addition
	lua_getglobal(L, "io");
	if(lua_isnil(L, 1) == 1)
		lua_createtable(L, 1, 0);
	
	// mtime
	lua_pushcfunction(L, lua_fstat_time);
	lua_setfield(L, -2, "mtime");
	
	lua_setglobal(L, "io");
	
	
	// os table addition
	lua_getglobal(L, "os");
	if(lua_isnil(L, 1) == 1)
		lua_createtable(L, 3, 0);
	
	// cwd
	lua_pushcfunction(L, lua_cwd_setcwd);
	lua_setfield(L, -2, "setcwd");
	lua_pushcfunction(L, lua_cwd_getcwd);
	lua_setfield(L, -2, "getcwd");
	lua_pushcfunction(L, lua_clear_window);
	
	// clear console
	lua_setfield(L, -2, "clear");
	
	lua_setglobal(L, "os");
	
	return 0;
}

