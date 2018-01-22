
#pragma once

#if defined(linux) || defined(__linux__) || defined(__linux)
#	define LUA_DLL	__attribute__((visibility("default")))
#elif defined(unix) || defined(__unix__) || defined(__unix)
#	define LUA_DLL	__attribute__((visibility("default")))
#elif defined(__APPLE__) || defined(__MACH__)
#	define LUA_DLL	__attribute__((visibility("default")))
#elif defined(_WIN32) || defined(_WIN64)
#	define LUA_DLL	__declspec(dllexport)
#else
#	error "OS not familiar. Set up headers accordingly, or -D__linux__ of -Dunix or -D__APPLE__ or -D_WIN32"
#endif
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
#else
#	warning "Please place the Lua version needed in './include' 'lua53/*' 'lua52/*' 'lua51/*' 'luajit51/*'"
#	error "Define the version you want to use with -D. '-DLUA_53' '-DLUA_52' '-DLUA_51' '-DLUA_JIT_51'"
#endif


#define LUA_DLL_ENTRY 	LUA_DLL int


LUA_DLL_ENTRY luaopen_luaadd(lua_State* L);

