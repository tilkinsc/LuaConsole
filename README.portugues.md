# LuaConsole
| Licença | Codecov.io | Gitter.im | Travis-CI | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF |  

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)


https://github.com/tilkinsc/LuaConsole  
Uma próxima geração, Plataforma Cruzada \[Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua5.3.x \] - suportando a CLI feita para substituir o interpretador PUC-Lua e LuaJIT  

Para mais informações, visite o [Site do LuaConsole Github] (https://tilkinsc.github.io/LuaConsole) e o [wiki] (https://github.com/tilkinsc/LuaConsole/wiki)!  

# Objetivos
* Seja um aplicativo CLI melhor que o PUC-Lua/LuaJIT
* Ter baixa cobertura de código para evitar que a redundância seja executada (0-30% de pseudo-objetivo)
* Suporta tudo compatível com PUC-Lua e LuaJIT
* Evite código confuso e ofuscante
* Seja CLI dependente e independente 

# Construção
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions

# Usando com o LuaRocks
https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support  

# Usando com o LuaDIST
https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS

# Testando
```bash
# Help command
luaw --help /? -?

# Modo REPL
luaw
luaw -p

# Do comando
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# Com os aprimoramentos do Shebang encontrados abaixo
res/testing.lua | luaw -Dtest=5 -n a b c -

# Usando cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# De dentro da Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# stdin:
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>

# No entanto, em vez dos dois acima, use: (pode negligenciar o implícito -p)
luaw -p
```

Específico do Windows:
```batch
REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>

REM Usando type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM Com os aprimoramentos do Windows Registry encontrados abaixo
res\testing.lua | luaw -Dtest=5 -n a b c -
res\testing | luaw -Dtest=5 -n a b c -
```

# Bônus
* [Windows Bonus Flashy Icons and Ease of Open](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
* Linux Bonus Shebangs -- WIP, not yet made
