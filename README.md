# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal + Lua's source console

### TODO
* Move additions to separate global table 'add'
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
testdll()  -> Loaded successfully!
```

Added very comprehensive error feedback, which tells you about the stack (stack dumps, too, if not just the error is on the stack), the type of error (syntax/runtime), and the regular lua feedback string with the line number sammich'd between two colons.

For example, <br>
>\>. <br>
>(Syntax) | Stack Top: 1 | [string "."]:1: unexpected symbol near '.' <br>

# Using with LuaRocks
[Windows MinGW](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Windows-MinGW)  
[Linux GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Linux-GCC)  
[Mac GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Mac-GCC)  

# Bonus
[Windows Bonus Flashy Icons and Ease of Open](https://github.com/Hydroque/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
