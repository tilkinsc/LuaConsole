# LuaConsole
| Лицензия | Codecov.io | Gitter.im | Travis-CI | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF |  

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)


https://github.com/tilkinsc/LuaConsole  
Кроссплатформенная следующего поколения \[Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua5.3.x \] поддерживающая CLI, заменяющая интерпретаторы PUC-Lua и LuaJIT  

Для получения дополнительной информации посетите [веб-сайт LuaConsole Github] (https://tilkinsc.github.io/LuaConsole) и [wiki] (https://github.com/tilkinsc/LuaConsole/wiki)!  

# цели
* Будьте лучшим приложением CLI, чем PUC-Lua/LuaJIT
* Низкое покрытие кода для предотвращения выполнения избыточности (псевдо-цель 0-30%)
* Поддержка всего совместимого с PUC-Lua и LuaJIT
* Предотвратить грязный, запутывающий код
* Быть зависимым от CLI и независимым 

# Строительство
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# Использование с LuaRocks
https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support   

# Использование с LuaDIST
https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS

# тестирование
```bash
# Справочная команда
luaw --help /? -?

# Режим REPL
luaw
luaw -p

# Из команды
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# С улучшениями Shebang, найденными ниже
res/testing.lua | luaw -Dtest=5 -n a b c -

# Изнутри cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# Изнутри Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# stdin:
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>

# Однако вместо двух вышеперечисленных используйте: (может пренебречь подразумеваемым -p)
luaw -p
```

Специфичный для Windows:
```batch
REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>

REM Изнутри type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM Используйте улучшения реестра, найденные ниже:
res\testing.lua | luaw -Dtest=5 -n a b c -
res\testing | luaw -Dtest=5 -n a b c -
```

# бонус
* [Windows Bonus Flashy Icons and Ease of Open](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
* Linux Bonus Shebangs -- WIP, not yet made
