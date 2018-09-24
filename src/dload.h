
#pragma once


#include "luaconf.h"
#undef LUALIB_API
#undef LUAMOD_API
#undef LUA_API
#define LUALIB_API typedef
#define LUAMOD_API typedef
#define LUA_API typedef


#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#if defined(LUA_JIT_51)
#	include "jitsupport.h"
#endif


#define dload(DLL, FUNC) _##FUNC = (FUNC*) GetProcAddress((DLL), (#FUNC))

lua_createtable* _lua_createtable;
lua_settable* _lua_settable;
lua_getfield* _lua_getfield;
lua_setfield* _lua_setfield;
lua_pushlstring* _lua_pushlstring;
lua_pushcclosure* _lua_pushcclosure;
lua_pushboolean* _lua_pushboolean;
lua_pushinteger* _lua_pushinteger;
lua_gettop* _lua_gettop;
#if !defined(_lua_getglobal) || !defined(_lua_setglobal)
	lua_setglobal* _lua_setglobal;
	lua_getglobal* _lua_getglobal;
#endif
lua_settop* _lua_settop;
lua_type* _lua_type;
lua_tolstring* _lua_tolstring;
lua_toboolean* _lua_toboolean;
#if defined(_lua_tonumber)
	lua_tonumberx* _lua_tonumberx;
#else
	lua_tonumber* _lua_tonumber;
#endif
lua_topointer* _lua_topointer;
lua_typename* _lua_typename;
#if defined(_lua_insert)
	lua_rotate* _lua_rotate;
#else
	lua_insert* _lua_insert;
#endif
#if defined(_lua_callk)
	lua_call* _lua_call;
#else
	lua_callk* _lua_callk;
#endif
#if defined(_lua_pcallk)
	lua_pcall* _lua_pcall;
#else
	lua_pcallk* _lua_pcallk;
#endif
lua_gc* _lua_gc;
lua_close* _lua_close;

#if defined(_luaL_loadbuffer)
	luaL_loadbufferx* _luaL_loadbufferx;
#else
	luaL_loadbuffer* _luaL_loadbuffer;
#endif
#if defined(_luaL_loadfile)
	luaL_loadfilex* _luaL_loadfilex;
#else
	luaL_loadfile* _luaL_loadfile;
#endif
luaL_callmeta* _luaL_callmeta;
#if LUA_VERSION_NUM > 501
	luaL_traceback* _luaL_traceback;
#endif
luaL_error* _luaL_error;
luaL_newstate* _luaL_newstate;
luaL_openlibs* _luaL_openlibs;
