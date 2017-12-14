# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal + Lua's source console

## TODO
* Add package manager support which people like to use
* Move additions to separate global table 'add'
* Ensure that it builds on linux and all includes are there and used
* Triple check buffer overflows and mem alignment and memleaks

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

This sure beats `print(type(data), data)` calls, and can be used to detect anything left on the stack in C. To add your own C functions, inherit the project and modify the additions.c file only.

Added very comprehensive error feedback, which tells you about the stack (stack dumps if not just the error is on the stack), the type of error (syntax/runtime), and the regular lua feedback string with the line number sammich'd between two colons.

For example, <br>
>\>. <br>
>(Syntax) | Stack Top: 1 | [string "."]:1: unexpected symbol near '.' <br>

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
