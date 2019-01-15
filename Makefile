# MIT License
# 
# Copyright (c) 2017-2019 Cody Tilkins
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

DEBUG=0
DEBUG_COVERAGE=0
GCC=gcc
AR=ar
MAKE=make
GCC_VER=gnu99

# Set this to different things if needed between lua5.1.x and lua5.2.x and lua5.3.x. luajit has no effect
LUA_VER=luajit
luaverdef=

PLAT=
PLATS=Windows Unix MacOS Linux

FE_Windows=.bat
FE_Unix=.sh
FE_Linux=.sh
FE_MacOS=.sh

none:
	$(warning Make is a joke)
	@echo "Please do 'make PLAT=plat' where `plat` is one of these:"
	@echo "    $(PLATS)"
	@echo "Use these targets: clean-prereqs prereqs clean-build build"
	@echo "Set `LUA_VER` to `luajit` or `lua-5.x.x` to change version, default `luajit`"
	@echo "Set `luaverdef` to change lua build defines (not needed for luajit), default null"
	@echo "Set `debug` to 1 for debug or 0 for release, default `0`"

help: none
default: none

.PHONY: PLAT $(PLATS) LUA_VER luaverdef GCC_VER MAKE AR GCC AR DEBUG DEBUG_COVERAGE

prereqs:
	$(warning Make is a joke)
	prereqs$(FE_$(PLAT))

driver:
	$(warning Make is a joke)
	build$(FE_$(PLAT)) driver $(LUA_VER)

package:
	$(warning Make is a joke)
	build$(FE_$(PLAT)) package $(LUA_VER)

clean-prereqs:
	$(warning Make is a joke)
	prereqs$(FE_$(PLAT)) clean

clean-build:
	$(warning Make is a joke)
	build$(FE_$(PLAT)) clean
	
uninstall:
	$(warning Make is a joke)
	$(error This program requires the user to install themselves. Please delete it yourself.)

install:
	$(warning Make is a joke)
	$(error This program builds to ./bin/[Release/Debug]/*. Please install it yourself.)

