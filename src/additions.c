/*
 * additions.c
 * 
 * Holds the additions functions to the console.
 * 
 */

#if defined(LUACON_ADDITIONS)

#	if defined(linux) || defined(__linux__) || defined(__linux)
#		include <unistd.h>
#		include <stdio.h>
#		include <stdlib.h>
#	elif defined(unix) || defined(__unix__) || defined(__unix)
#		include <unistd.h>
#		include <stdio.h>
#		include <stdlib.h>
#	elif defined(__APPLE__) || defined(__MACH__)
#		include <unistd.h>
#		include <stdio.h>
#		include <stdlib.h>
#	elif defined(_WIN32) || defined(_WIN64)
#		include <windows.h>
#		include <stdio.h>
#		include <stdlib.h>
#		include <dirent.h>
#	else
#		error "Not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#	endif

#	include <time.h>
#	include <sys/types.h>
#	include <sys/stat.h>

#	include "additions.h"

#	include "lua.h"
#	include "lualib.h"
#	include "lauxlib.h"


#	if defined(_WIN32) || defined(_WIN64)
#		define CLEAR_CONSOLE "cls"
#	else
#		define CLEAR_CONSOLE "clear"
#	endif


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
			fprintf(stdout, "%d:(Boolean):%s\n", i, lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			fprintf(stdout, "%d:(Number):%g\n", i, lua_tonumber(L, i));
			break;
		case LUA_TFUNCTION:
			fprintf(stdout, "%d:(Function):@%p\n", i, lua_topointer(L, i));
			break;
		case LUA_TTABLE:
			fprintf(stdout, "%d:(Table):@%p\n", i, lua_topointer(L, i));
			break;
		default:
			fprintf(stdout, "%d:(Object):%s:@%p\n", i, lua_typename(L, t), lua_topointer(L, i));
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



int luaopen_additionsdll(lua_State* L) {
	
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

#endif

