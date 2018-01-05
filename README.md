# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal + Lua's source console  
Works on Linux, Windows, and Mac.  

### TODO  
* Add LuaJIT as an external dependancy and create an overlay for functionality of LuaJIT... pretty much inherit... probably front end or a modified build to DLL or something idk  
* Develop the additions package with more standard functions that lua could definitely use... maybe not idk  
* Optimize REPL \- the code is meh  
* Play with sigints and longjmps to see if it could bring a cool feature
* Support multiple lua states on separate threads
* I wonder if its possible to serialize a lua\_State sufficiently, would be nice to save an env
* português translation?

# About
<details><summary>lua -?</summary><p>
Lua Console | Version: 1/5/2017<br>
Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio<br>
LuaConsole Copyright MIT (C) 2017 Hydroque<br>

Supports Lua5.3, Lua5.2, Lua5.1   

        - Files executed by passing  
        - Global variable defintions  
        - Dynamic module loading  
        - PUC-Lua compatibility support  
        - Working directory support  
        - Built in stack-dump  
        - Console clearing  

Usage: lua.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-p] [-a] [-c] [-Dvar=val]  
[-Lfilepath.lua] [-b[a,b,c]] [-?] [-n]{parameter1 ...}  
  
-v       Prints the Lua version in use  
-e       Prevents lua core libraries from loading  
-s       Issues a new root path  
-p       Has console post exist after script in line by line mode  
-a       Disables the additions  
-c       No copyright on init  
-d       Defines a global variable as value after '='  
-l       Executes a module before specified script  
-b[a,b,c]        Load parameters arg differently. a=before passed -l's, b=give p  
assed -l's a tuple, c=give passed file a tuple  
-n       Start of parameter section  
-?       Displays this help message  
</p>
</details>
<details><summary>luaw -?</summary><p>  
Lua Console | Version: 1/5/2017<br>
Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio<br>
LuaConsole Copyright MIT (C) 2017 Hydroque<br>
  
Supports Lua5.3, Lua5.2, Lua5.1  
  
        - Line by Line interpretation  
        - Files executed by passing  
        - Global variable defintions  
        - Dynamic module loading  
        - PUC-Lua compatibility support  
        - Working directory support  
        - Built in stack-dump  
        - Console clearing  

Usage: lua.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-p] [-a] [-c] [-Dvar=val]  
[-Lfilepath.lua] [-b[a,b,c]] [-?] [-n]{parameter1 ...}  

-v       Prints the Lua version in use  
-e       Prevents lua core libraries from loading  
-s       Issues a new root path  
-p       Has console post exist after script in line by line mode  
-a       Disables the additions  
-c       No copyright on init  
-d       Defines a global variable as value after '='  
-l       Executes a module before specified script or post-exist  
-b[a,b,c]        Load parameters arg differently. a=before passed -l's, b=give p  
assed -l's a tuple, c=give passed file a tuple  
-n       Start of parameter section  
-?       Displays this help message  
</p>
</details>

A console whose code is much easier to look at and handle than the one provided native with Lua. Has more functionality with native lua console. Supports everything Lua's console does except multiline support in-post-exist. Runs compiled source without a problem. Use -? to get a list of the switches above (different depending on how you build it). Support for LuaRocks is in the wiki. Want to contribute? Submit a pull request. Want to report a bug? Start an issue. Ideas? Start an issue.

# Additions

There is an 'additions' module to this interpreter, which is completely up to the user to utilize. You can temporarily disable them with the -a switch, or even keep them out of your build. Doing so will take away the added `os.getcwd()` and `os.setcwd(string)` and `stackdump(...)` and `os.clear()` functions, which let you set the current working directory and view your stack. A clear function also has been added, which uses the nasty system() call as well as use clear (cls only on windows). Lua Console acts much like a console now that the additions were added. 

stackdump() is a global function. It works as easy as print does, but it does type conversion from lua to C-string and lists anything left in the stack.

For example, <br>
>\>stackdump(1, {}, function() end, "hello") <br>
>--------------- Stack Dump ---------------- <br>
>4:(String):`hello` <br>
>3:(Function):@007214C0 <br>
>2:(Table):@0072A258 <br>
>1:(Number):1 <br>
>----------- Stack Dump Finished ----------- <br>

This sure beats `print(type(data), data)` calls, and can be used to detect anything left on the stack in C. To add your own C functions, inherit the project and modify the additions.c file only. Another method to adding C functions is creating a similar dll/so file:
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
This is how LuaRocks does it, but they have file formats and containers. Everything LuaRocks compiles down to a dll/so or two, gets loaded, then taken over by whatever lua script loaded it. Then just compile and run it in lua:
```
gcc -g0 -O2 -Wall -c testdll.c
gcc -g0 -O2 -Wall -shared -o testdll.dll testdll.o
```
```
testdll = package.loadlib("testdll.dll", "luaopen_testdll")
print(testdll) -> function
testdll()  -> Loaded successfully!
```

Added very comprehensive error feedback, which tells you about the stack (stack dumps, too, if not just the error is on the stack), the type of error (syntax/runtime), and the regular lua feedback string with the line number sammich'd between two colons. Now with file name!

For example,  
> $luaw res/testing.lua  
> (Runtime) | Stack Top: 1 | res/testing.lua:18: attempt to call a nil value (fie  
> ld 'whatever')  
> \-\-  
> stack traceback:  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;res/testing.lua:18: in main chunk  

# Using with LuaRocks
[Windows MinGW](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Windows-MinGW)  
[Linux GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Linux-GCC)  
[Mac GCC](https://github.com/Hydroque/LuaConsole/wiki/LuaRocks-Support-Mac-GCC)  

# Bonus
[Windows Bonus Flashy Icons and Ease of Open](https://github.com/Hydroque/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
