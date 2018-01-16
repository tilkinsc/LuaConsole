
# TODO:
# - need to handle files from dll well
# - need to copy *.dll to bin/Debug or bin/Release
# - make sure to exclude all dummy files except those in res

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

DEBUG_BIN_DIR = $(BDIR)\Debug
RELEASE_BIN_DIR = $(BDIR)\Release

LIBS_DIR = -L. -Lsrc -Llib -Ldll
INCL_DIR = -I. -Isrc -Iinclude


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
Windows: luaw luaadd.dll test

Unix: LIBS = -llua51.dll -ldl -lm
Unix: CFLAGS += -DLUA_JIT_51
Unix: luaw luaadd.so test
	

luaadd.dll: $(LUAADD.DLL_OBJS)
	$(CC) -shared $(CFLAGS) -DLUACON_ADDITIONS -o $(BIN_DIR)/$@ $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)

luaadd.so: $(LUAADD.SO_OBJS)
	$(CC) -shared $(CFLAGS) -Wl,-E -DLUACON_ADDITIONS -o $(BIN_DIR)/$@ $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)


luaw: $(LUAW_OBJS)
	$(CC) $(CFLAGS) -o $(BIN_DIR)/$@$(EXE_SUFFIX) $(subst $(SDIR),$(ODIR),$^) $(LIBS) $(LLIBS)



.PHONY: clean

clean:
	-$(RM) $(ODIR)/*.o
