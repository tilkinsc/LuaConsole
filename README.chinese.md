# LuaConsole
| 执照 | Codecov.io | Gitter.im | Travis-CI | Appveyor |
| ------- | ---------- | --------- | --------- | -------- |
| [![License](https://img.shields.io/github/license/tilkinsc/LuaConsole.svg)](https://github.com/tilkinsc/LuaConsole/blob/master/LICENSE) | [![Codecov](https://codecov.io/gh/tilkinsc/LuaConsole/coverage.svg?branch=master)](https://codecov.io/gh/tilkinsc/LuaConsole) | [![Gitter.im](https://badges.gitter.im/tilkinsc/LuaConsole.png)](https://gitter.im/LuaConsole) | [![travis-ci](https://travis-ci.org/tilkinsc/LuaConsole.svg?branch=master)](https://travis-ci.org/tilkinsc/LuaConsole) | ![appveyor](https://ci.appveyor.com/api/projects/status/github/tilkinsc/LuaConsole?svg=true) OFF |  

[![English](https://i.imgur.com/koEsWJi.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.md)
[![Spanish](https://i.imgur.com/6eQwrN2.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.espanol.md)
[![Portuguese](https://i.imgur.com/MQ1ArnU.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.portugues.md)
[![Russian](https://i.imgur.com/cuby3uW.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.russian.md)
[![Chinese](https://i.imgur.com/pDy0fs3.png)](https://github.com/tilkinsc/LuaConsole/blob/master/README.chinese.md)


https://github.com/tilkinsc/LuaConsole  
下一代，跨平台 \[Lua-5.1.x，LuaJIT-2.0，Lua-5.2.x，Lua5.3.x \] 支持 CLI 取代 PUC-Lua 和 LuaJIT 解释器  

有关更多信息, 请访问[LuaConsole Github网站]（https://tilkinsc.github.io/LuaConsole）和[wiki]（https://github.com/tilkinsc/LuaConsole/wiki）！  

# 目标
* 比 PUC-Lua/LuaJIT 更好的 CLI 应用程序
* 具有低代码覆盖率以防止执行冗余（0-30% 伪目标）
* 支持与 PUC-Lua 和 LuaJIT 兼容的所有内容
* 防止混乱, 混淆代码
* 取决于 CLI 并且是独立的

# 建造
[Windows/Unix Build Instructions](https://github.com/tilkinsc/LuaConsole/wiki/Build-Instructions)  

# 与 LuaRocks一起使用
[Windows MinGW](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Windows-MinGW)  
[Linux GCC](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Linux-GCC)  
[Mac GCC](https://github.com/tilkinsc/LuaConsole/wiki/LuaRocks-Support-Mac-GCC)  

# 与 LuaDIST一起使用
[Windows/Unix LuaDIST](https://github.com/tilkinsc/LuaConsole/wiki/LuaDist-Support-Windows,-Linux,-MacOS)

# 测试
```bash
# 帮助命令
luaw --help /? -?

# REPL 模式
luaw
luaw -p

# 从命令
luaw res/testing.lua -Dtest=5 -n a b c
luaw -lres/testing.lua -Dtest=5 -n a b c
luaw -Dtest=5 -n a b c - < res/testing.lua

# 在下面找到 Shebang 增强功能
res/testing.lua | luaw -Dtest=5 -n a b c -

# 使用 cat
cat res/testing.lua | luaw -Dtest=5 -n a b c -

# 从 Lua 里面
luaw -e "dofile('res/testing.lua')" -Dtest=5 -n a b c
luaw -e "dofile('testing.lua')" -s res -Dtest=5 -n a b c

# stdin:
luaw -
dofile('res/testing.lua')
<Ctrl + d>
<Enter>

# 但是, 请使用以下代码: (可以忽略隐含的 -p)
luaw -p
```

Windows 特定:
```batch
REM stdin
luaw -
dofile('res/testing.lua')
<Ctrl + z>
<Enter>

REM 使用 type
type res\testing.lua | luaw -Dtest=5 -n a b c -

REM 使用下面的 Windows Registry 增强功能
res\testing.lua | luaw -Dtest=5 -n a b c -
res\testing | luaw -Dtest=5 -n a b c -
```

# 奖金
* [Windows Bonus Flashy Icons and Ease of Open](https://github.com/tilkinsc/LuaConsole/wiki/Windows-Bonus---Flashy-Icons-and-Ease-of-Open)  
* Linux Bonus Shebangs -- WIP, not yet made
