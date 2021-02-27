# LuaConsole

[![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) 

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![German]()]()
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)

[![Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?business=RCR8HT8GDC5XC&item_name=Free+Software&currency_code=USD)

https://github.com/tilkinsc/LuaConsole  
Eine plattformübergreifende CLI der nächsten Generation [Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua-5.3.x, Lua-5.4.x], die PUC-Lua und LuaJIT CLI ersetzt

Weitere Informationen finden Sie auf der [LuaConsole Github-Website](https://tilkinsc.github.io/LuaConsole) und im [Wiki](https://github.com/tilkinsc/LuaConsole/wiki)!  

# Ziele
* Seien Sie eine bessere CLI-Anwendung als PUC-Lua/LuaJIT
* Unterstützen Sie alles, was mit PUC-Lua und LuaJIT kompatibel ist
* Verhindern Sie unordentlichen, verschleierten Code
* Seien Sie CLI-abhängig und unabhängig  
* Multiplattform - Linux, Windows, Mac (inoffiziell)

# Build
[Windows/Linux Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# Verwendung mit LuaRocks
[LuaRocks Support](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support)  

# Verwendung mit LuaDIST
[LuaDist Support Windows, Linux, MacOS](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)  

# Testen

### Linux
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
res/testing.lua -Dtest=5 -n a b c

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
```

### Windows
```batch
REM Help command
luaw --help /? -?

REM REPL Mode
luaw
luaw -p

REM From the command
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

REM With Windows Registry enhancements found below
res\testing.lua -Dtest=5 -n a b c
res\testing -Dtest=5 -n a b c

REM Using type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM From inside Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>
```

# Bonus
* [Windows Bonus - Flashy Icons & Registry Enhancements](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus----Flashy-Icons-&-Registry-Enhancements)  
* [Linux Bonus - Shebangs & Desktop Files](https://github.com/tilkinsc/LuaConsole/wiki/Linux-Bonus---Shebangs-&-Desktop-Files)

