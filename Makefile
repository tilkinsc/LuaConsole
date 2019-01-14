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

TYPE=release

CFLAGS_release=-std=gnu11 -s -Wall -O2
CFLAGS_debug=-std=gnu11 -Wall -g -O0

# set to -coverage for code coverage
DEBUG_COVERAGE=
# NO_ADDITIONS=0 # doesn't work, not implemented

LUA_VER_DEF=-DLUA_JIT_51
LUA_VER=-lluajit-5.1
LUA_INC=.

ROOT_release=bin/Release
ROOT_debug=bin/Debug

ODIR=obj
LDIR=lib
RDIR=res
ROOT=root
DLLS=dll
SDIR=src
IDIR=include
	
DIRS=-L$(SDIR) -L$(LDIR) -L$(DLLS)-I$(SDIR) -I$(IDIR) -I$(LUA_INC)

ROOTDIR=$(ROOT_$(TYPE))
CFLAGS_END=$(CFLAGS_$(TYPE))

Windows:
	$(warning Make is a joke)
	@if EXIST $(ROOTDIR) ( rmdir /S /Q $(ROOTDIR) )
	@mkdir $(ROOTDIR)/res
	echo Compiling luaw...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) $(LUA_VER_DEF) -D__USE_MINGW_ANSI_STDIO -c $(SDIR)/consolew.c $(SDIR)/jitsupport.c $(SDIR)/darr.c
	echo Linking luaw...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) -o luaw.exe consolew.o jitsupport.o darr.o $(DLLS)/lua51.dll
	if $(TYPE) EQU release strip --strip-all luaw.exe
	echo Compiling additions...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) $(LUA_VER_DEF) -D__USE_MINGW_ANSI_STDIO -c $(SDIR)/additions.c
	echo Linking additions...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) -shared -o luaadd.dll additions.o $(DLLS)/lua51.dll
	
	
	-move /Y *.dll $(ROOTDIR) 1>nul 2>nul
	-move /Y *.o $(ODIR) 1>nul 2>nul
	-move /Y *.a $(ODIR) 1>nul 2>nul
	-move /Y *.exe $(ROOTDIR) 1>nul 2>nul
	-copy /Y $(DIR)/* $(ROOTDIR)/res 1>nul 2>nul
	-copy /Y $(DLLS)/* $(ROOTDIR) 1>nul 2>nul
	-copy /Y $(ROOT)/* $(ROOTDIR) 1>nul 2>nul
	
MacOS: Unix
Linux: Unix

Unix:
	$(warning Make is a joke)
	@if [ -d $(ROOTDIR) ]; then rm -r --one-file-system -d $(ROOTDIR); fi
	@mkdir -p $(ROOTDIR)/res
	echo Compiling luaw...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) $(LUA_VER_DEF) -c $(SDIR)/consolew.c $(SDIR)/jitsupport.c $(SDIR)/darr.c
	echo Linking luaw...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) -o luaw.exe consolew.o jitsupport.o darr.o -lluajit-5.1 -lm -ldl
	if [ $debug -eq 1 ]; then strip --strip-all luaw; fi
	echo Compiling additions...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) $(LUA_VER_DEF) -Wl,-E -fPIC -c $(SDIR)/additions.c
	echo Linking additions...
	gcc $(CFLAGS_END) $(DEBUG_COVERAGE) $(DIRS) -shared -Wl,-E -fPIC -o luaadd.o additions.o -lluajit-5.1
	chmod +x luaw
	
	-mv *.so $(ROOTDIR) 1>/dev/null 2>/dev/null
	-mv *.o $(ODIR) 1>/dev/null 2>/dev/null
	-mv *.a $(ODIR) 1>/dev/null 2>/dev/null
	-mv luaw $(ROOTDIR) 1>/dev/null 2>/dev/null
	-cp -r $(RDIR)/* $(ROOTDIR)/res 1>/dev/null 2>/dev/null
	-cp -r $(DLLS)/* $(ROOTDIR) 1>/dev/null 2>/dev/null
	-cp -r $(ROOT)/* $(ROOTDIR) 1>/dev/null 2>/dev/null
	
uninstall:
	$(error This program requires the user to install themselves. Please delete it yourself.)
install:
	$(error This program builds to ./bin/*, please install it yourself.)

