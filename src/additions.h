/* MIT License
 * 
 * Copyright (c) 2017-2018 Cody Tilkins
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



#define LUA_DLL_ENTRY 	LUA_DLL int


LUA_DLL_ENTRY luaopen_luaadd(lua_State* L);

