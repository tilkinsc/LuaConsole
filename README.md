# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal + Lua's source console  
Works on Linux, Windows, and Mac.  

### TODO  
* Recode a lot of luajit.c into consolew.c for superceeding support
* signal() in all modes so whole program can exit gracefully
* Develop the additions package with more standard functions that lua could definitely use... maybe not idk  
* Check with supporting spawning new threads entirely with its own lua_State* (as opposed to coroutines)
* Check about serializing the environment to jump back in when not luajit (as it should already be supported)
* português translation ( ͡° ͜ʖ ͡°)

# About
<details><summary>luaw -?</summary><p>  
Lua Console | Version: 1/8/2017<br>
Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio<br>
LuaConsole Copyright MIT (C) 2017 Hydroque<br>

Supports Lua5.3, Lua5.2, Lua5.1<br>

        - Files executed by passing<br>
        - Global variable defintions<br>
        - PUC-Lua and LuaJIT compatible<br>
        - Dynamic module loading<br>
        - Built-in stack-dump<br>
        - Line by Line interpretation<br>

Usage: luaw.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-p] [-a] [-c]<br>
        [-Dvar=val] [-Lfilepath.lua] [-b[a,b,c]] [-?] [-n]{parameter1 ...}<br>

-v               Prints the Lua version in use<br>
-e               Prevents lua core libraries from loading<br>
-s               Issues a new root path<br>
-p               Has console post exist after script in line by line mode<br>
-c               No copyright on init<br>
-d               Defines a global variable as value after '='<br>
-l               Executes a module before specified script or post-exist<br>
-b[a,b,c]        Load parameters arg differently. a=before passed -l's,<br>
                        b=give passed -l's a tuple, c=give passed file a tuple<br>
-n               Start of parameter section<br>
-?               Displays this help message<br>
</p>
</details>

A console whose code is much easier to look at and handle than the one provided native with Lua. Has more functionality with native lua console. Supports everything Lua's console does except multiline support in-post-exist. Runs compiled source without a problem. Use -? to get a list of the switches above (different depending on how you build it). Support for LuaRocks is in the wiki. Want to contribute? Submit a pull request. Want to report a bug? Start an issue. Ideas? Start an issue.

# Building
Just two steps:
1. get Lua
2. build LuaConsole
[Here are instructions.](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions) I didn't exactly go into detail, but you can use build.lua with the outdated PUC-Lua interpreter if you edit it and define `plat=Windows` or `plat=Linux` or `plat=MacOSX` before the requires as a global. Call it extra insult to injury if you want, but its cute.

<details><summary>Testing</summary><p> 

```  
C:\git\LuaConsole>bin\Debug\luaw.exe -lres/testing.lua -r "print(({...})[1]);" -
Dtest=5 -Bacd -p -v -n a b c
Copyright (C) 1994-2008 Lua.org, PUC-Rio
LuaConsole Copyright MIT (C) 2017 Hydroque
Lua 5.1
a
3
3
1       a       string
2       b       string
3       c       string
1       a       string
2       b       string
3       c       string
5
 (Runtime) | Stack Top: 1 | res/testing.lua:20: attempt to call field 'whatever'
 (a nil value)
 --
stack traceback:
        res/testing.lua:20: in main chunk
>os.exit()
```

</p></details><br>

# Additions
<details><summary>About</summary><p>  
Added full, very comprehensive error reporting.  

There is an 'additions' module to this interpreter, which is completely up to the user to utilize. You can even keep them out of your build. It is recommended to use them, as build.lua depends on it.  

void stackdump() works as easy as print does, but it does type conversion from lua to C-string and lists anything left in the stack.  

For example, <br>
>\>stackdump(1, {}, function() end, "hello") <br>
>--------------- Stack Dump ---------------- <br>
>4:(String):`hello` <br>
>3:(Function):@007214C0 <br>
>2:(Table):@0072A258 <br>
>1:(Number):1 <br>
>----------- Stack Dump Finished ----------- <br>

Number io.mtime(string) returns the last modified time of a file.  

void os.clear() clears the console using System("cls") or System("clear") depending on the OS.  

String os.getcwd() returns the current working directory  

void os.setcwd(string) sets the current working directory  
</p></details>  

<details><summary>Extending</summary><p>
To add your own C functions, inherit the project and modify the additions.c file only. The perferred method is to add C functions by creating a dll/so file:  

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

This is how LuaRocks does it, but they are very high level. Everything LuaRocks compiles down to a dll/so or two, gets loaded, then taken over by whatever lua script loaded it. Then just compile and run it in lua:  

```
gcc -g0 -O2 -Wall -c testdll.c
gcc -g0 -O2 -Wall -shared -o testdll.dll testdll.o
```  

```
testdll = package.loadlib("testdll.dll", "luaopen_testdll")
print(testdll) -> function
testdll()  -> Loaded successfully!
-- if the file `testdll.dll` lines up with "luaopen_testdll" where the file name is the function name, use require
-- require("testdll")
```  

</p></details>  

# Using with LuaRocks
[Windows MinGW](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Windows-MinGW)  
[Linux GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Linux-GCC)  
[Mac GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Mac-GCC)  

# Bonus
[Windows Bonus Flashy Icons and Ease of Open](https://github.com/Hydroque/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
