# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal

# About

Lua Console | Version: 5/6/2017

Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio

LuaConsole Copyright MIT (C) 2017 Hydroque

- Line by Line interpretation
- Files executed by passing
- Working directory support
- Built in stack-dump
- Supports Lua5.3, Lua5.2, Lua5.1

A console whose code is much easier to look at and handle than the one provided native with Lua. Supports everything Lua's console does except multiline support and (really just untested) pre-compiled lua source. Use -? to get a list of the switches. Should work on linux as well as mac and windows. If it doesn't make a pull request and/or start an issue.

# Additions

There is an 'additions' package to this interpretor, which is completely up to the user to use. You can temporarily disable them with the -a switch. Doing so will take away the added `os.getcwd()` and `os.setcwd(string)` commands, which let you set the current working directory. A clear function also has been added, which should keep support of only consoles which accept the nasty system() call as well as use clear (cls only on windows), which is mapped to `os.clear()`. Lua Console acts much like a console now that the additions were added.

Added a function called stackdump(), which is a global function. It works as easy as print does, but it does type conversion from lua to C and lists anything left off the stack.

For example, <br>
>\>stackdump(1, {}, function() end, "hello") <br>
>--------------- Stack Dump ---------------- <br>
>4:(String):`hello` <br>
>3:(Function):@007214C0 <br>
>2:(Table):@0072A258 <br>
>1:(Number):1 <br>
>----------- Stack Dump Finished ----------- <br>

This sure beats `print(type(data), data)` calls, and can be used to detect anything left on the stack in C. To add your own C functions, inherit the project.

Added comprehensive error feedback, which tells you about the stack (stack dumps if not just the error is on the stack), the type of error (syntax/runtime), and the regular lua feedback string with the line number sammich'd between two colons.

For example, <br>
>\>. <br>
>(Syntax) | Stack Top: 1 | [string "."]:1: unexpected symbol near '.' <br>

# Bonus

Put luaw.exe into C:\Windows\System32 and use resource hacker program (3rd party program) to put an icon into your .exe at -1, and enjoy this context menu edit as well as graphics with the .reg script below. Use at your own discression. I can't be held accountable for you breaking your system, as registry is pretty delicate.
- allows to double click to run script files
- right click Post-Exist allows to keep lua console open
- see a cool icon on all your .lua files
- get a cool icon on your .exe
- (can add ;.LUA to EXTS env variable so you don't have to type in full name to run the file, eg run.lua > run)

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\DefaultIcon]
@="C:\\windows\\System32\\luaw.exe,-1"

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\open]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\open\command]
@="\"C:\\Windows\\System32\\luaw.exe\" \"%1\""

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\Post-Exist]

[HKEY_CURRENT_USER\Software\Classes\Applications\luaw.exe\shell\Post-Exist\command]
@="luaw.exe %1 -p"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua\OpenWithList]
"a"="luaw.exe"
"MRUList"="a"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lua\UserChoice]
"Progid"="Applications\\luaw.exe"
```
