# LuaConsole

[![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) 

[![English](https://user-images.githubusercontent.com/7494772/109406669-0a75d500-7949-11eb-87fa-b56ee60e2afd.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://user-images.githubusercontent.com/7494772/109406678-24171c80-7949-11eb-94d7-83afe3befae0.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![German](https://user-images.githubusercontent.com/7494772/109406691-3002de80-7949-11eb-83ee-95967d986e99.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.german.md)
[![Portuguese](https://user-images.githubusercontent.com/7494772/109406785-e49d0000-7949-11eb-8b36-793272d7821e.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://user-images.githubusercontent.com/7494772/109406798-f5e60c80-7949-11eb-9467-947936c47188.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://user-images.githubusercontent.com/7494772/109406811-0c8c6380-794a-11eb-82dc-c06a322448ff.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)

[![Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?business=RCR8HT8GDC5XC&item_name=Free+Software&currency_code=USD)

https://github.com/tilkinsc/LuaConsole  
Uma próxima geração, Cross-Platform [Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua-5.3.x, Lua-5.4.x] de suporte CLI feita para substituir PUC-Lua e LuaJIT CLI 

Para obter mais informações, visite [LuaConsole Github Website] (https://tilkinsc.github.io/LuaConsole) e o [wiki] (https://github.com/tilkinsc/LuaConsole/wiki)! 

# Metas
* Ser um aplicativo CLI melhor do que PUC-Lua/LuaJIT
* Suporta tudo compatível com PUC-Lua e LuaJIT
* Evite códigos confusos e ofuscantes
* Seja dependente e independente da CLI
* Multiplataforma - Linux, Windows, Mac (não oficial) 

# Construir
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions

# Usando com LuaRocks
[LuaRocks Support](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support)  

# Usando com LuaDIST
[LuaDist Support Windows, Linux, MacOS](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)  

# Testar

## Linux
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

## Windows
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
# Extra
* [Windows Bonus - Flashy Icons & Registry Enhancements](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus----Flashy-Icons-&-Registry-Enhancements)  
* [Linux Bonus - Shebangs & Desktop Files](https://github.com/tilkinsc/LuaConsole/wiki/Linux-Bonus---Shebangs-&-Desktop-Files)
