# Welcome to LuaConsole Website


| License | Codecov.io | Gitter.im | Travis-cl | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) N/A |  

### About

The project came to life when I realized how bad PUC-Lua and LuaJIT's REPL interpreters were.
I took action and started development on a brand new REPL interpreter around May 1, 2017.

Copyright information: [LuaConsole License](https://tilkinsc.github.io/LuaConsole/LICENSE) - [Lua License](https://tilkinsc.github.io/LuaConsole/Lua%20LICENSE) - [LuaJIT License](https://tilkinsc.github.io/LuaConsole/LuaJIT%20LICENSE)

LuaConsole is a Cross-Platform CLI application designed to support Lua-5.1.x, Lua-5.2.x, Lua-5.3.x, and LuaJIT-2.0 while not breaking compatibility, but also adding some very QOL features. The at-birth goal for LuaConsole was to be better than PUC-Lua in terms of pretty code, more operation, and less bugs. Soon after, I took a look at LuaJIT and reworked it... after exporting some functions to learn (and fix) them aka `jitsupport.c`. One other step was `luaadd.dll` which adds a few debug things such as stack_dump() and mainly just current directory and terminal clearing, but was later scrapped because it made the repo too complex. It is in a perfect place to be extensable enough to support Lua-5.0 and earlier.

### Collaborators (1)

* [tilkinsc](https://github.com/tilkinsc)

### Getting Started

First, download and build Lua then LuaConsole [HERE].(https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)


_____

**Things wrong with PUC-Lua REPL interpreter (1/13/2019):**
* Poor formatted command line help message
* Mashed up, not spaced properly, weird tabs, string-line cutting aka column 80, etc
* Code was horrifying to look at and hard to follow through, very complex names, functions not ordered
* It was a maintainers nightmare
* Redundant code, you don't need to pass args to pmain, even luajit doesn't do that
* Full help/usage not layed out. `[options]` means a lot for ordering, doesn't it...
* Lack of support for different versions of switches (-, /) aka windows vs linux switches
* Folling into: parameters couldn't be combined, thanks `[options]` (can't `lua -e "print(arg[1], arg[2])" arg1 arg2`)
* Readline library is actually only useful for those who knew what they were doing
* Bulk was not features: When the line numbers matched between LuaConsole and PUC-Lua, LuaConsole had much more functionality and full support lua51, lua52, and lua53 (can't remember if jit too, prob not)
* There was too much pushing to the stack for no reason when you could just preprocess the information or something
* PUC-Lua hasn't updated their console much [since 2003 lua5.0](https://www.lua.org/versions.html)
* No features are likely in development
* luajit only conforms with changes to PUC-Lua REPL
* PUC-Lua easily deprecated in favor for LuaJIT variation: fast, the addition of -j, -O, and -b
* I found it hard to use stdout when parsing things with lua because the copyright
* No support for -Ddefine=value variables (i.e. dynamic environments)
* Working directory support is 0, probably need io package revamped tbh
* -l worked, but never before -e so you can use it
* You didn't know where to put the -l, nor when it executed
* (Opinion) Multi-line support was bad? and unused
1. Nobody was really aware, esp how to use
2. One liners in REPL are perfectly do-able, else just | and type your stuff
3. CLIs don't support multiline to far extents outside of terminals
4. Why not just create a file on the fly so you can edit it and not clunkily span through the lines of code with buttons you have to remember, you know `echo "whatever" > out.lua && type out.lua | luaw -p -`
5. Don't type stories anyways because you WILL have a syntax error, idk the quality of the multiline history readline has
* Non-comprehensive error reporting
1. Lua error message without traceback
2. No ability to tell if your stack is not being popped
3. Syntax versus Runtime not obvious
4. Non-string non-userdata error returns not fully supported

**Things wrong with LuaJIT REPL interpreter (9/13/2019):**
* All problems from PUC-Lua REPL interpreter persisted
* Code derived still very messy
* Lack of proactive improvement/maintenance
1. [No features are likely in development](https://github.com/tilkinsc/LuaConsole/wiki/LuaJIT-Readme)
* Bug with `print_jit_status` where things were left pushed to stack still not fixed (see link above)
* Weird usage of macro with `LJ_TARGET_CONSOLE` (as if it built as no-REPL)
* Needless single-use functions which aren't in-lined
* Defines lacked () guards
* Preprocessed everything it needed in `pamin` instead of `main`
* Forces you to install rather than migrate binaries
* Weird binary names

**Improvements made (1/13/2019):**
* Attempts at a really good help message
* Supports all types of switches -,/ but only --help for --
* 100% fresh, maintainable code with proper names for forkers
* No external libraries needed thus far, but requests for readline and gettext have been made
* Attempt at relieving bulk useless code, 31% code coverage :D, see travis and codecov
* Command line arguments work as expected with arguments getting their chance to work
* Supports Lua-5.1.x, Lua-5.2.x, Lua-5.3.x and LuaJIT-2.0
* Supersedes use-ability of `PUC-Lua and LuaJIT`
* Full support for shared lua dll/.lua libraries with `-L` switch
* No multi-line support? Maybe I need a vim clone :P
* Fixed bugs in `print_jit_status`
* Attempts to conform to LuaJIT and PUC-Lua but not enforce standards with features
* Proper defines with () guards
* All preprocessing goes in main instead of lua-functions, smaller size, less needless complexity
* Supports Windows, Linux/headless, and Mac (unix compatible afaik)
* Use -D to define global variables, which transverses tables
* Working directory support
* Gracefully exits... most of the time... its really user-dependent if you exit or not
* LuaRocks and LuaDist can be used
* Proper signal (CTRL-C) support
* Ability to squelch copyright so you can do lua -e "print(1, 2, 3)" and collect the stdout
* Determine how you handle parameters with -t
* Installation doesn't have to be in a specific directory, so AIO workspaces are enabled
* Ability to switch lua version with executable call `luaw -w lua-5.3.5 -e 'print(":)")'`


