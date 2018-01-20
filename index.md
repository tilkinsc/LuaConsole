# Welcome to LuaConsole Website

### About

The project came to life when I realized how bad PUC-Lua and LuaJIT's REPL interpreters were.
I took action and started development on a brand new REPL interpreter around May 1, 2017.

Copyright information: [LuaConsole License](https://hydroque.github.io/LuaConsole/LICENSE) [Lua License](https://hydroque.github.io/LuaConsole/Lua LICENSE)

Things wrong with PUC-Lua REPL interpreter (1/20/2018):
* Badly formatted command line help message
* Lack of support for different versions of switches (-, /, \\)
* Code was horrifying and hard to follow through, complex names
* Used unneeded external libraries
* Bulk was not features
* Broken command line arguments (can't lua -e "print(arg[1], arg[2])" arg1 arg2)
* Lack of proactive improvement/maintenance
* Easily depreciated in favor for LuaJIT variation
* Lacked major features/necessities
* In the way of manually building an archive or a shared library
* Lacked proper support for library inclusion whether shared library or .lua file
* Multi-line support was bad and unused and unnecessary
* Lack of current directory support
* Bug when exiting a script into REPL mode
* Bad error reporting

Things wrong with LuaJIT REPL interpreter (1/20/2018):
* All problems from PUC-Lua REPL interpreter persisted
* Code derived still very messy
* Lack of proactive improvement/maintenance
* Bug with `print_jit_status` where things were left pushed to stack
* Weird usage of macro with `LJ_TARGET_CONSOLE` (as if it built as no-REPL)
* Enforced standards
* Needless single-use functions which aren't in-lined
* Defines lacked () guards
* Preprocessed everything it needed in `pamin` instead of `main`

Improvements made (1/20/2018):
* Best darn command line help message you ever seen
* Supports all types of switches
* 100% new, fresh, maintainable code with proper names
* No external libraries needed
* No added bulk
* Command line arguments work as expected
* Maintained
* Supports Lua5.1, Lua5.2, Lua5.3 and LuaJIT5.1
* Supersedes what LuaJIT derived
* External from Lua source as to require lua .dll/.dll.a/.so/.so.a/.a
* Full support for shared libraries with `-L` switch
* No multi-line support bulk
* Current directory can be set two different ways
* Never exits to REPL mode unless a script isn't present or you ask it to
* Fixed bugs in `print_jit_status`
* Everything is for a purpose when it comes to macros
* Attempts to conform but not enforce standards (admit it, compatibility in lua is :( )
* Proper defines with ()
* All preprocessing goes in main instead of lua-functions
* Supports Windows, Linux, and Mac seamlessly
* Small file sizes
* Use -D to define global variables, which transverses tables
* Working directory support
* Gracefully exits
* Copyright squelch for stdout collection
* LuaRocks ready
* Proper signal support

### Collaborators 

* [Hydroque](https://github.com/Hydroque)

### Getting Started

First, download and build Lua and LuaConsole:
* [Windows Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#Windows) | [Windows LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#windows-1)
* [Linux Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#linux) | [Linux LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#linux-1)
* [MacOSX Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#mac-osx) | [MacOSX LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#mac-osx)


#### LuaAdd

Supplied with LuaConsole is a shared library called `luaadd`. The intent of luaadd is lua additions that are useful in a cmd/terminal environment.
You CAN trash it. It is dynamically loaded into lua using require.

| Return   | Prototype           | Action                                         |
|----------|---------------------|------------------------------------------------|
| _Number_ | io.mtime(_String_)  | returns the last modified time of a file       |
| _void_   | os.clear()          | clears the console using a System() call       |
| _String_ | os.getcwd()         | returns the current process' working directory |
| _void_   | os.setcwd(_String_) | sets the current working directory             |
| _void_   | stackdump(_..._)    | prints stack-dump format of anything passed    |


