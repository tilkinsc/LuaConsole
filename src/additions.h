
#pragma once

#include "lua53/lua.h"

#define LUA_DLL			__declspec(dllexport)
#define LUA_DLL_ENTRY 	LUA_DLL int


LUA_DLL_ENTRY luaopen_luaadd(lua_State* L);

