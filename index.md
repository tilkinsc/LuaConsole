# Welcome to LuaConsole Website

### About

The project came to life when I realized how bad PUC-Lua and LuaJIT's REPL interpreters were.
I took action and started development on a brand new REPL interpreter around May 1, 2017.

Copyright information: [LuaConsole License](https://hydroque.github.io/LuaConsole/LICENSE) - [Lua License](https://hydroque.github.io/LuaConsole/Lua LICENSE) - [LuaJIT License](https://hydroque.github.io/LuaConsole/LuaJIT LICENSE)

### Collaborators 

* [Hydroque](https://github.com/Hydroque)

### Getting Started

First, download and build Lua then LuaConsole:
| OS | LuaConsole Instructions |
| -- | ----------------------- |
| [Windows Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#Windows) | [Windows LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#windows-1) |
| [Linux Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#linux) | [Linux LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#linux-1) |
| [MacOSX Lua](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#mac-osx) | [MacOSX LuaConsole](https://github.com/Hydroque/LuaConsole/wiki/Build-Instructions#mac-osx) |

_____

**Things wrong with PUC-Lua REPL interpreter (8/2/2018):**
* Poor formatted command line help message
1. Mashed up
2. Not spaced
3. Full help/usage not layed out. `[options]` means a lot for ordering, doesn't it
* Lack of support for different versions of switches (-, /)
1. Windows felt odd
2. Linux felt odd
3. Inability to use both bothered me 
* Code was horrifying and hard to follow through, complex names
1. It was a maintainers nightmare
2. Created a lot of redundancy
3. Functions weren't even oraganized in code
* Used unneeded external libraries
1. This increased the executable size
2. Made the input very not dynamic
3. Replaced by only a few lines
4. Readline library was actually useful for those who didn't know what they were doing
* Bulk was not features
1. When the line numbers matched between LuaConsole and PUC-Lua, mine had more functionality and full support
2. There was too much pushing to the stack for no reason when you could just preprocess the information or something
* Broken command line arguments (can't `lua -e "print(arg[1], arg[2])" arg1 arg2`)
1. From the lack of command line arguments they have, this can be the only problem
2. I had like 3 use cases for this when using PUC-Lua (especially automation)
3. You had to pipe the code instead using --
* Lack of proactive improvement/maintenance
1. PUC-Lua hasn't updated their console much [since 2003 lua5.0](https://www.lua.org/versions.html)
2. No features are likely in development
3. luajit only conforms with changes to PUC-Lua REPL
* PUC-Lua easily deprecated in favor for LuaJIT variation
1. The addition of -j, -O, and -b deprecated luac, too
2. Faster
3. Slightly easier to read
* Lacked major features/necessities
1. I found it hard to use stdout when parsing things with lua becuase the copyright
2. No support for -Ddefine=value variables (i.e. dynamic environments)
3. Working directory support is 0
* Lacked proper support for library inclusion whether shared library or .lua file
1. -l worked, but never before -e so you can use it
2. You didn't know where to put the -l, nor when it executed
* (Opinion) Multi-line support was bad and unused and unnecessary
1. Hardly anyone really uses this
2. One liners in REPL is perfectly do-able
3. CLIs don't support multiline to far extents
4. Why not just create a file on the fly so you can edit it and not clunkily span through the lines of code with buttons you have to remember, you know `echo "whatever" > out.lua && luaw out.lua`
5. It has abysmal effects on your history
6. One liner functions are perfectly do-able, don't type stories anyways because you WILL have a syntax error
* Noncomprehensive error reporting
1. Lua error message with traceback
2. No ability to tell if your stack is not being popped

**Things wrong with LuaJIT REPL interpreter (8/2/2018):**
* All problems from PUC-Lua REPL interpreter persisted
* Code derived still very messy
* Lack of proactive improvement/maintenance
1. [No features are likely in development](https://github.com/tilkinsc/LuaConsole/wiki/LuaJIT-Readme)
* Bug with `print_jit_status` where things were left pushed to stack still not fixed (see link above)
* Weird usage of macro with `LJ_TARGET_CONSOLE` (as if it built as no-REPL)
1. Only ommited a few functions
2. Forced two executables to be present
* Needless single-use functions which aren't in-lined
* Defines lacked () guards
* Preprocessed everything it needed in `pamin` instead of `main`
* Relied on Readline support still, I guess for backwards compatibility thats fine

**Improvements made (8/2/2018):**
* Attempt at a really good help message
* Supports all types of switches -,/ but only --help for --
* 100% fresh, maintainable code with proper names for forkers
* No external libraries needed
* Attempt at relieving bulk useless code
* Command line arguments work as expected with arguments
* Maintained, to some degree ;)
* Supports Lua5.1, Lua5.2, Lua5.3 and LuaJIT5.1
* Supersedes PUC-Lua, which LuaJIT derived while supporting either, but not at once yet
* Easy and optional support of using .dll/.so or .a when building LuaConsole
* Full support for shared lua dll/.lua libraries with `-L` switch
* No multi-line support? Maybe I need a vim clone :P
* Current directory can be set two different ways, -s and using luaadd
* Fixed bugs in `print_jit_status`
* Attempts to conform to LuaJIT and PUC-Lua but not enforce standards
* Proper defines with () guards
* All preprocessing goes in main instead of lua-functions, smaller size, less needless complexity
* Supports Windows, Linux/headless, and Mac
* Small file size due to ability to lack .a and no bulk
* Use -D to define global variables, which transverses tables
* Working directory support
* Gracefully exits
* Copyright squelch for stdout collection
* LuaRocks can be used
* Proper signal (CTRL-C) support
* Ability to squelch copyright so you can do lua -e "print(1, 2, 3)" and use it
* Determine how you handle parameters with -t


#### LuaAdd

Supplied with LuaConsole is a shared library called `luaadd`. The intent of luaadd is lua additions that are useful in a cmd/terminal environment.
You CAN trash it. It is dynamically loaded into lua using require.

| Return   | Prototype           | Action                                         |
|----------|---------------------|------------------------------------------------|
| _Number_ | io.mtime(_String_)  | returns the last modified time of a file       |
| _Table_  | io.dir(_String_)    | returns the files/directories from passed path |
| _void_   | os.clear()          | clears the console using a System() call       |
| _String_ | os.getcwd()         | returns the current process' working directory |
| _void_   | os.setcwd(_String_) | sets the current working directory             |
| _void_   | stackdump(_..._)    | prints stack-dump format of anything passed    |


