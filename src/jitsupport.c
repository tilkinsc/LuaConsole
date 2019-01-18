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
 
#if defined(LUA_JIT_51)
#	include "jitsupport.h"

#	include "lang.h"

#	define _(str) langfile_get(lang, str)
	
	// lang cache
	extern LangCache* lang;
	
	// LuaJIT functions slightly modified for LuaConsole
	// TODO: optimize
	//	Write a error handler?
	//	Support non string returns?
	//	Normalize error messages
	//	Fix weird passing of jitargs
	//	Mash some of this in few functions as possible
	//	
	
	
	// Load add-on module
	int loadjitmodule(lua_State* L) {
		lua_getglobal(L, "require");
		lua_pushliteral(L, "jit.");
		lua_pushvalue(L, -3);
		lua_concat(L, 2);
		if (lua_pcall(L, 1, 1, 0)) {
			const char *msg = lua_tostring(L, -1);
			if (msg && !strncmp(msg, "module ", 7))
				goto nomodule;
			msg = lua_tostring(L, -1);
			if(msg == NULL) msg = _("JS_NOT_A_STRING");
			fprintf(stderr, _("JS_ERROR"), msg);
			lua_pop(L, 1);
			return 1;
		}
		lua_getfield(L, -1, "start");
		if (lua_isnil(L, -1)) {
	nomodule:
			fputs(_("JS_BAD_COMMAND"), stderr);
			return 1;
		}
		lua_remove(L, -2); // Drop module table
		return 0;
	}

	// Run command with options
	int runcmdopt(lua_State* L, const char* opt) {
		int narg = 0;
		if (opt && *opt) {
			for (;;) { // Split arguments
				const char *p = strchr(opt, ',');
				narg++;
				if (!p) break;
				if (p == opt)
					lua_pushnil(L);
				else
					lua_pushlstring(L, opt, (size_t)(p - opt));
				opt = p + 1;
			}
			if (*opt)
				lua_pushstring(L, opt);
			else
				lua_pushnil(L);
		}
		int status = 0;
		if((status = lua_pcall(L, narg, 0, 0)) != 0) {
			const char* msg = lua_tostring(L, -1);
			if(msg == NULL) msg = _("JS_NOT_A_STRING");
			fprintf(stderr, _("JS_ERROR"), msg);
			lua_pop(L, 1);
		}
		return status;
	}

	// JIT engine control command: try jit library first or load add-on module
	int dojitcmd(lua_State* L, const char* cmd) {
		const char *opt = strchr(cmd, '=');
		lua_pushlstring(L, cmd, opt ? (size_t)(opt - cmd) : strlen(cmd));
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit"); // Get jit.* module table
		lua_remove(L, -2);
		lua_pushvalue(L, -2);
		lua_gettable(L, -2); // Lookup library function
		if (!lua_isfunction(L, -1)) {
			lua_pop(L, 2); // Drop non-function and jit.* table, keep module name
			if (loadjitmodule(L)) {
				return 1;
			}
		} else
			lua_remove(L, -2); // Drop jit.* table
		lua_remove(L, -2); // Drop module name
		return runcmdopt(L, opt ? opt+1 : opt);
	}

	// Optimization flags
	int dojitopt(lua_State* L, const char* opt) {
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit.opt"); // Get jit.opt.* module table
		lua_remove(L, -2);
		lua_getfield(L, -1, "start");
		lua_remove(L, -2);
		return runcmdopt(L, opt);
	}

	// Save or list bytecode
	int dobytecode(lua_State* L, char** argv) {
		int narg = 0;
		lua_pushliteral(L, "bcsave");
		if (loadjitmodule(L))
			return 1;
		if (argv[0][2]) {
			narg++;
			argv[0][1] = '-';
			lua_pushstring(L, argv[0]+1);
		}
		for (argv++; *argv != NULL; narg++, argv++)
			lua_pushstring(L, *argv);
		int status = 0;
		if((status = lua_pcall(L, narg, 0, 0)) != 0) {
			const char* msg = lua_tostring(L, -1);
			if(msg == NULL) msg = _("JS_NOT_A_STRING");
			fprintf(stderr, _("JS_ERROR"), msg);
			lua_pop(L, 1);
		}
		return status;
	}

	// Prints JIT settings
	void print_jit_status(lua_State* L) {
		lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
		lua_getfield(L, -1, "jit");
		lua_remove(L, -2);
		lua_getfield(L, -1, "status");
		lua_remove(L, -2); // _LOADED.jit.status
		int n = lua_gettop(L);
		lua_call(L, 0, LUA_MULTRET);
		fputs(lua_toboolean(L, n) ? _("JS_JIT_ON") : _("JS_JIT_OFF"), stdout);
		const char* s = NULL;
		for (n++; (s = lua_tostring(L, n)); n++) {
			putc(' ', stdout);
			fputs(s, stdout);
		}
		putc('\n', stdout);
		lua_pop(L, lua_gettop(L) - n);
	}


	int jitargs(lua_State* L, Array* luajit_jcmds, Array* luajit_opts, char** luajit_bc, int squelch, int post_exist) {
		if(luajit_jcmds != NULL) {
			for(size_t i=0; i<luajit_jcmds->size; i++)
				if(dojitcmd(L, (const char*) array_get(luajit_jcmds, i)) != 0)
					fputs(_("JS_FAILED_CONTROL_CMD"), stderr);
			array_free(luajit_jcmds);
		}

		if(luajit_opts != NULL) {
			for(size_t i=0; i<luajit_opts->size; i++)
				if(dojitopt(L, (const char*) array_get(luajit_opts, i)) != 0)
					fputs(_("JS_FAILED_SET_O"), stderr);
			array_free(luajit_opts);
		}
		
		if(squelch == 0 && post_exist == 1)
			print_jit_status(L);
		
		if(luajit_bc != NULL)
			return dobytecode(L, luajit_bc);
		return 0; // success
	}

#endif // EOF if defined(LUA_JIT_51)

