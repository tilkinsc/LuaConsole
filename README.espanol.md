# LuaConsole
| Licencia | Codecov.io | Gitter.im | Travis-CI | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF |  

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)


https://github.com/tilkinsc/LuaConsole  
Una próxima generación, multiplataforma \[Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua5.3.x \] - CLI de respaldo para reemplazar a la PUC-Lua y al intérprete LuaJIT  

Para más información, visite [LuaConsole Github Website](https://tilkinsc.github.io/LuaConsole) y el [wiki](https://github.com/tilkinsc/LuaConsole/wiki)!  

# Metas
* Sea una mejor aplicación de CLI que PUC-Lua/LuaJIT
* Tener una baja cobertura de código para evitar que se ejecute la redundancia (0-30% pseudo-meta)
* Apoya todo lo compatible con PUC-Lua y LuaJIT
* Evitar el código desordenado
* Ser dependiente e independiente de CLI

# Edificio
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# Usando con LuaRocks
https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support  

# Usando con LuaDIST
https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS

# Pruebas
```bash
# Help command
luaw --help /? -?

# Modo REPL
luaw
luaw -p

# Desde el comando
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# Con las mejoras de Shebang que se encuentran a continuación
res/testing.lua | luaw -Dtest=5 -n a b c -

# Usando cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# Desde dentro de Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# stdin:
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>

# Sin embargo, en lugar de los dos anteriores, use: (puede descuidar lo implícito -p)
luaw -p
```

Windows Específico:
```batch
REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>

REM Utilizando el type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM Con las mejoras de `Windows Registry` que se encuentran a continuación
res\testing.lua | luaw -Dtest=5 -n a b c -
res\testing | luaw -Dtest=5 -n a b c -
```

# Prima
* [Windows Bonus Flashy Icons and Ease of Open](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
* Linux Bonus Shebangs -- WIP, not yet made
