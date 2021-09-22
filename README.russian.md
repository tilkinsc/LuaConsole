# LuaConsole
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
[![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) [![Build status](https://ci.appveyor.com/api/projects/status/3rqh0vn8a0lm8itg?svg=true)](https://ci.appveyor.com/project/Hydroque/luaconsole)

[![English](https://user-images.githubusercontent.com/7494772/109406669-0a75d500-7949-11eb-87fa-b56ee60e2afd.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://user-images.githubusercontent.com/7494772/109406678-24171c80-7949-11eb-94d7-83afe3befae0.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![German](https://user-images.githubusercontent.com/7494772/109406691-3002de80-7949-11eb-83ee-95967d986e99.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.german.md)
[![Portuguese](https://user-images.githubusercontent.com/7494772/109406785-e49d0000-7949-11eb-8b36-793272d7821e.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://user-images.githubusercontent.com/7494772/109406798-f5e60c80-7949-11eb-9467-947936c47188.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://user-images.githubusercontent.com/7494772/109406811-0c8c6380-794a-11eb-82dc-c06a322448ff.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)

[![Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?business=RCR8HT8GDC5XC&item_name=Free+Software&currency_code=USD)

[LuaConsole](https://github.com/tilkinsc/LuaConsole) - это [Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua-5.3.x, Lua-5.4.x] совместимый кросс-платформенный интерфейс командной строки следующего поколения, призванный заменить PUC-Lua и LuaJIT CLI

Для получения дополнительной информации посетите [Веб-сайт LuaConsole Github](https://tilkinsc.github.io/LuaConsole) и [Вики LuaConsole Github](https://github.com/tilkinsc/LuaConsole/wiki)!

## Цели

* Быть лучшим CLI-приложением, чем PUC-Lua/LuaJIT
* Поддержка всего, что совместимо с PUC-Lua и LuaJIT
* Предотвратить беспорядочный, запутывающий код
* Иметь возможность зависеть или не зависеть от интерфейса командной строки
* Мультиплатформенность - Linux, Windows, Mac (неофициально)

## Сборка

[Инструкции по сборке на Windows/Unix](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

## Использование с LuaRocks

[Поддержка LuaRocks](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support)  

## Использование с LuaDIST

[Поддержка LuaDist на Windows, Linux, MacOS](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)  

## Тестирование

### Linux

```bash
# Команда помощи
luaw --help /? -?

# Режим REPL
luaw
luaw -p

# Из команды
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# С улучшенным шебангом
res/testing.lua -Dtest=5 -n a b c

# Используя cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# Из-под Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# Используя stdin
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>
```

### Windows

```batch
REM Команда помощи
luaw --help /? -?

REM Режим REPL
luaw
luaw -p

REM Из команды
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

REM С улучшениями Реестра Windows 
res\testing.lua -Dtest=5 -n a b c
res\testing -Dtest=5 -n a b c

REM Используя тип
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM Из-под Lua
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>
```

## Дополнительно

* [Windows бонус - Яркие значки и улучшения реестра](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus----Flashy-Icons-&-Registry-Enhancements)  
* [Linux бонус - шебанги и файлы рабочего стола](https://github.com/tilkinsc/LuaConsole/wiki/Linux-Bonus---Shebangs-&-Desktop-Files)

## Участники ✨

Спасибо этим замечательным людям ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://darkwiiplayer.com"><img src="https://avatars.githubusercontent.com/u/1252859?v=4?s=100" width="100px;" alt=""/><br /><sub><b>DarkWiiPlayer</b></sub></a><br /><a href="https://github.com/tilkinsc/LuaConsole/commits?author=DarkWiiPlayer" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

Этот проект следует спецификации [all-contributors](https://github.com/all-contributors/all-contributors). Любое участие приветствуется!
