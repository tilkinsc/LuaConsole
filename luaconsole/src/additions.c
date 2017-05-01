/*
 * additions.c
 *
 *  Created on: Apr 30, 2017
 *      Author: Bud
 */

#if defined(__linux__) || defined(__unix__)
#include <unistd.h>
#else
#include <dirent.h>
#endif

#include <stdio.h>
#include <stdlib.h>

#include "additions.h"

#include "lua.h"


#ifdef _WIN32
#define CLEAR_CONSOLE "cls"
#else
#define CLEAR_CONSOLE "clear"
#endif



int stackDump(lua_State *L) {
	int i = lua_gettop(L);
	printf("--------------- Stack Dump ----------------\n");
	while(i) {
		int t = lua_type(L, i);
		switch (t) {
		case LUA_TSTRING:
			printf("%d:(String):`%s`\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			printf("%d:(Boolean):%s\n", i, lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			printf("%d:(Number):%g\n", i, lua_tonumber(L, i));
			break;
		default:
			printf("%d:(Object):%s\n", i, lua_typename(L, t));
			break;
		}
		i--;
	}
	printf("----------- Stack Dump Finished -----------\n");
	return 0;
}

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

void additions_add(lua_State* L) {
	
	// stack dump addition
	lua_pushcfunction(L, stackDump);
	lua_setglobal(L, "stackdump");
	
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
}

