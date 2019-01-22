# LuaConsole
| License | Codecov.io | Gitter.im | Travis-CI | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF |  

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)


https://github.com/tilkinsc/LuaConsole  
A next-gen, Cross-Platform \[Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua5.3.x\]-supporting CLI made to supersede PUC-Lua and LuaJIT interpreter  

For more information, visit [LuaConsole Github Website](https://tilkinsc.github.io/LuaConsole) and the [wiki](https://github.com/tilkinsc/LuaConsole/wiki)!  

# Goals
* Be a better CLI application than PUC-Lua/LuaJIT
* Have low code-coverage to prevent redundancy being executed (0-30% pseudo-goal)
* Support everything compatible with PUC-Lua and LuaJIT
* Prevent messy, obfuscating code
* Be CLI dependant and independant  

# Building
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# Using with LuaRocks
[Windows MinGW](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Windows-MinGW)  
[Linux GCC](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Linux-GCC)  
[Mac GCC](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Mac-GCC)  

# Using with LuaDIST
[Windows/Unix LuaDIST](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)

# Testing
```bash
# Help command
luaw --help /? -?

# REPL Mode
luaw
luaw -p

# From the command
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# With Shebang enhancements found below
res/testing.lua | luaw -Dtest=5 -n a b c -

# Using cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# From inside Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# stdin:
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>

# However, instead of the above two, use: (can neglect the implied -p)
luaw -p
```

Windows Specific:
```batch
REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>

REM Using type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM With Windows Registry enchancements found below
res\testing.lua | luaw -Dtest=5 -n a b c -
res\testing | luaw -Dtest=5 -n a b c -
```

# Bonus
* [Windows Bonus Flashy Icons and Ease of Open](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
* Linux Bonus Shebangs -- WIP, not yet made
