
#pragma once

#if defined(LUACON_ADDITIONS)

#	include "lua.h"

#	define LUA_DLL			__declspec(dllexport)
#	define LUA_DLL_ENTRY 	LUA_DLL int


LUA_DLL int stack_dump(lua_State* L);

LUA_DLL_ENTRY luaopen_additionsdll(lua_State* L);


#endif

