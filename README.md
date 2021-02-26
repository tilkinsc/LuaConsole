# LuaConsole

| License | Codecov.io | Gitter.im | Travis-CI | Appveyor | Contributers |
| ------- | ---------- | --------- | --------- | -------- | ------------ |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF | [![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-) |

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)

[![Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?business=RCR8HT8GDC5XC&item_name=Free+Software&currency_code=USD)

https://github.com/tilkinsc/LuaConsole  
A next-gen, Cross-Platform [Lua-5.1.x, LuaJIT-2.0, Lua-5.2.x, Lua-5.3.x, Lua-5.4.x]-supporting CLI made to supersede PUC-Lua and LuaJIT CLI  

For more information, visit [LuaConsole Github Website](https://tilkinsc.github.io/LuaConsole) and the [wiki](https://github.com/tilkinsc/LuaConsole/wiki)!  

# Goals
* Be a better CLI application than PUC-Lua/LuaJIT
* Support everything compatible with PUC-Lua and LuaJIT
* Prevent messy, obfuscating code
* Be CLI dependent and independent  
* Multiplatform - Linux, Windows, Mac (unofficial)

# Building
[Windows/Linux Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# Using with LuaRocks
[LuaRocks Support](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support)  

# Using with LuaDIST
[LuaDist Support Windows, Linux, MacOS](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)  

# Testing

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

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

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

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
