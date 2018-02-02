
# TODO: Ensure this happens under `directories:` target
# - need to copy *.dll/so to bin/Debug or bin/Release
# - need to copy res/* to bin/Debug/res or bin/Release/res
# - need to copy root/* to bin/Debug or bin/Release
# - target-specific tools are utilized
# - removed embedded lua -l's

# TODO: Improvements
# - improve the environment setup system
# - obviously support external lua directories/ -D's

# MIT License
# 
# Copyright (c) 2017-2018 Cody Tilkins
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

ifeq ($(PLAT), )
	$(error Please define PLAT= `Windows`, `Unix`)
endif

# Directory stuff
CC = gcc
RM = del
CP = copy
MKDIR = mkdir
RMDIR = rmdir /S /q

ODIR = obj
SDIR = src
IDIR = include
LDIR = lib
DDIR = dll
BDIR = bin
RDIR = res
ROOT = root

LIBS_DIR = -L. -Lsrc -Llib -Ldll
INCL_DIR = -I. -Isrc -Iinclude

DEBUG_BIN_DIR = $(BDIR)\Debug
RELEASE_BIN_DIR = $(BDIR)\Release


# Compiler/Linker setup
DEBUG = -g2 -O0
RELEASE = -s -g0 -O2

EXE_SUFFIX = .exe
BIN_DIR = $(DEBUG_BIN_DIR)
CFLAGS = $(DEBUG) -Wall $(LIBS_DIR) $(INCL_DIR)

HEADERS = $(wildcard $(SDIR)/*.h)
LLIBS = $(wildcard $(LDIR)/*.a) $(wildcard $(DDIR)/*.dll) $(wildcard $(DDIR)/*.so)


LUAW_OBJS = $(addprefix $(SDIR)/, consolew.o darr.o)
LUAADD.DLL_OBJS = $(addprefix $(SDIR)/, additions.o)
LUAADD.SO_OBJS = $(addprefix $(SDIR)/, additions.o)


# Merge all O's into $(ODIR) from $(SDIR)
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $(subst $(SDIR),$(ODIR),$@)

default: directories $(PLAT)

directories:
	-$(RMDIR) $(BIN_DIR)
	-$(MKDIR) $(BIN_DIR)
	-$(MKDIR) $(BIN_DIR)\$(RDIR)
	-$(CP) $(RDIR)\* $(BIN_DIR)\$(RDIR)
	-$(CP) $(ROOT)\* $(BIN_DIR)
	-$(CP) $(DDIR)\* $(BIN_DIR)

Windows: LIBS = -llua51.dll
Windows: CFLAGS += -D__USE_MINGW_ANSI_STDIO=1 -DLUA_JIT_51
Windows: luaw luaadd.dll

Unix: LIBS = -lluajit-5.1 -ldl -lm
Unix: CFLAGS += -DLUA_JIT_51
Unix: luaw luaadd.so
	

luaadd.dll: $(LUAADD.DLL_OBJS)
	$(CC) -shared $(CFLAGS) -DLUACON_ADDITIONS -o $(BIN_DIR)/$@ $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)

luaadd.so: $(LUAADD.SO_OBJS)
	$(CC) -shared $(CFLAGS) -Wl,-E -DLUACON_ADDITIONS -o $(BIN_DIR)/$@ $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)


luaw: $(LUAW_OBJS)
	$(CC) $(CFLAGS) -o $(BIN_DIR)/$@$(EXE_SUFFIX) $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)


# many things need added
.PHONY: clean

# clean needs improved
clean:
	-$(RM) $(ODIR)/*.o
