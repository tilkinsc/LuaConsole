# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal + Lua's source console

### TODO
* Move additions to separate global table 'add'
* Ensure that it builds on linux and all includes are there and used
* Triple check buffer overflows and mem alignment and memleaks
* Add `-l string` option to allow dll's to be loaded easier

# About

Lua Console | Version: 9/26/2017
Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio
LuaConsole Copyright MIT (C) 2017 Hydroque

- Line by Line interpretation
- Files executed by passing argument
- Working directory support addition
- Built in stack-dump addition
- Console clear addition
- Supports Lua5.3, Lua5.2, Lua5.1

A console whose code is much easier to look at and handle than the one provided native with Lua. Supports everything Lua's console does except multiline support. Runs compiled source without a problem. Use -? to get a list of the switches. Should work on linux as well as mac and windows. If it doesn't make a pull request and/or start an issue.

# Additions

There is an 'additions' module to this interpretor, which is completely up to the user to utilize. You can temporarily disable them with the -a switch, or even keep them out of your build. Doing so will take away the added `os.getcwd()` and `os.setcwd(string)` and `stackdump(...)` and `os.clear()` functions, which let you set the current working directory and view your stack. A clear function also has been added, which should uses the nasty system() call as well as use clear (cls only on windows). Lua Console acts much like a console now that the additions were added. 

stackdump() is a global function. It works as easy as print does, but it does type conversion from lua to C-string and lists anything left in the stack.

For example, <br>
>\>stackdump(1, {}, function() end, "hello") <br>
>--------------- Stack Dump ---------------- <br>
>4:(String):`hello` <br>
>3:(Function):@007214C0 <br>
>2:(Table):@0072A258 <br>
>1:(Number):1 <br>
>----------- Stack Dump Finished ----------- <br>

This sure beats `print(type(data), data)` calls, and can be used to detect anything left on the stack in C. To add your own C functions, inherit the project and modify the additions.c file only. Another method to adding C functions is creating a similar dll file:
```

#include <stdio.h>
#include "lua.h"

#define DLL_EXPORT	__declspec(dllexport)
#define LUA_DLL_EXPORT	DLL_EXPORT int

LUA_DLL_EXPORT luaopen_testdll(lua_State *L) {
	// TODO: load things into the lua_State
	puts("Loaded successfully!");
	return 0;
}
```
This is how LuaRocks does it, but they have file formats and containers. Everything LuaRocks compiles down to a dll or two, gets loaded, then taken over by whatever lua script loaded it. Then just compile and run load it in lua:
```
gcc -g0 -O2 -Wall -c testdll.c
gcc -g0 -O2 -Wall -shared -o testdll.dll testdll.o
```
```
testdll = package.loadlib("testdll.dll", "luaopen_testdll")
print(testdll) -> function
testdll()  -> Loaded!
```

Added very comprehensive error feedback, which tells you about the stack (stack dumps, too, if not just the error is on the stack), the type of error (syntax/runtime), and the regular lua feedback string with the line number sammich'd between two colons.

For example, <br>
>\>. <br>
>(Syntax) | Stack Top: 1 | [string "."]:1: unexpected symbol near '.' <br>

# Using with LuaRocks
## Windows MinGW
1. Download lua version of choice or collect the .a or .dll you use
2. Download luarocks latest
3. cd in cmd to luarocks
4. Run `install /F /MW /L`, installs to `C:\Program Files (x86)\LuaRocks`
5. Delete all lua5.1 executables, manifest, and lua51.dll
6. Add in your own version lua.dll or liblua.a
7. Rename config-5.1.lua to match your version (config-5.1, config-5.2, etc), and
8. Edit it
```
variables = {
	CC = "gcc"; -- your gcc name
	LD = "gcc"; -- your gcc name
    LUALIB = 'liblua53.a'; -- name of added library whether .a or .dll
}
```
9. Edit `lua\luarocks\site_config.lua`
```
site_config.LUA_INTERPRETER=[[luaw]] -- name of lua interpreter exe
site_config.LUAROCKS_UNAME_S=[[MINGW]]
```
10. Edit `luarocks.bat` to point to your LuaConsoleW executable, and pass the arguments correctly
```
REM I keep my luaw LuaConsoleW executable in my path, should be on line 12 or something
"luaw" "C:\Program Files (x86)\LuaRocks\luarocks.lua" -Dcommand="%*"
```
11. Edit `luarocks.lua` to ship your commands, whilst still allowing use for the old console from lua
```
#!/usr/bin/env lua

print(command)
if(type(command) == "string")then
	local temp = {}
	command = command:gsub("[^%s]+", function(str)
		table.insert(temp, str)
	end)
	command = temp
end
command = command or ...

-- this should be loaded first.
local cfg = require("luarocks.cfg")

local loader = require("luarocks.loader")
local command_line = require("luarocks.command_line")

program_description = "LuaRocks main command-line interface"

commands = {
   help = "luarocks.help",
   pack = "luarocks.pack",
   unpack = "luarocks.unpack",
   build = "luarocks.build",
   install = "luarocks.install",
   search = "luarocks.search",
   list = "luarocks.list",
   remove = "luarocks.remove",
   make = "luarocks.make",
   download = "luarocks.download",
   path = "luarocks.path_cmd",
   show = "luarocks.show",
   new_version = "luarocks.new_version",
   lint = "luarocks.lint",
   write_rockspec = "luarocks.write_rockspec",
   purge = "luarocks.purge",
   doc = "luarocks.doc",
   upload = "luarocks.upload",
   config = "luarocks.config_cmd",
}

command_line.run_command(table.unpack(command))
```
12. Ensure that LuaRocks is in path for both `\_ENV.package` your evironment variable path, easy just to have a batch file and load it once per instance of cmd. However, actually setting an environment variable to add using 'Using' [program](https://gist.github.com/Hydroque/f6718ca61d76085b064c3dca02f96017) by `using %env_var%` is a better choice. That way you can also work on exporting a lot of things out of your path that doesn't need to be in there.
```
@echo off

set lua_ver_str=5.3
set userdir=%HOMEDRIVE%%HOMEPATH%
set luarocksdir=C:\Program Files (x86)\LuaRocks

SET LUA_PATH=%userdir%\AppData\Roaming/luarocks/share/lua/%lua_ver_str%/?.lua;%userdir%\AppData\Roaming/luarocks/share/lua/%lua_ver_str%/?/init.lua;%luarocksdir%\systree/share/lua/%lua_ver_str%/?.lua;%luarocksdir%\systree/share/lua/%lua_ver_str%/?/init.lua;%luarocksdir%/lua/?.lua;%luarocksdir%\lua\?.lua;%luarocksdir%\lua\?\init.lua;
SET LUA_CPATH=%userdir%\AppData\Roaming/luarocks/lib/lua/%lua_ver_str%/?.dll;%luarocksdir%\systree/lib/lua/%lua_ver_str%/?.dll;%windir%\system32\?.dll;%windir%\system32\..\lib\lua\%lua_ver_str%\?.dll;%windir%\system32\loadall.dll;.\?.dll
SET PATH=%userdir%\AppData\Roaming/luarocks/bin;%luarocksdir%\systree/bin;%luarocksdir%;%path%
```

# Bonus

Put luaw.exe into C:\Windows\System32 and use resource hacker program (3rd party program) to put an icon into your .exe at -1, and enjoy this context menu edit (as well as graphics with the .reg script below). Use at your own discression. I can't be held accountable for you breaking your system, as registry is pretty delicate. This was written for windows 7, so it may differ in 10 except for XP.
- allows to be in the common path
- see a cool icon on all your .lua files
- get a cool icon on your .exe
- (can add ;.LUA to EXTS env variable so you don't have to type in full name to run the file, eg "run" instead of "run.lua")
- call files like this: `luafile.lua -Dtest=5 -p -n a b c` (which runs luafile.lua with luaw.exe, defines global test = 5, and sets args to {a, b, c}, and finally post-exists to use the interpretor)

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\DefaultIcon]
@="C:\\windows\\System32\\luaw.exe,-1"

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\open]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\open\command]
@="\"C:\\Windows\\System32\\luaw.exe\" \"%1\" %*"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua\OpenWithList]
"a"="luaw.exe"
"MRUList"="a"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua\UserChoice]
"Progid"="Applications\\luaw.exe"
```
