#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2017-2021 Cody Tilkins
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


# Default env vars
if [ -z "$debug" ]; then			debug=0;			fi
if [ -z "$debug_coverage" ]; then	debug_coverage=0;	fi
if [ -z "$GCC" ]; then				GCC="gcc";			fi
if [ -z "$OBJCOPY" ]; then			OBJCOPY="objcopy";	fi
if [ -z "$AR" ]; then				AR="ar";			fi
if [ -z "$MAKE" ]; then				MAKE="make";		fi
if [ -z "$GCC_VER" ]; then			GCC_VER=gnu99;		fi


# On help message request
function help_message() {
	echo "Usage:"
	echo ""
	echo "		build.bat build lua-x.x.x              Builds the driver with a default package"
	echo "		build.bat package lua-x.x.x            Creates packages for the driver"
	echo "		build.bat clean                        Cleans the environment of built files"
	echo "		build.bat install [directory]          Installs to a pre-created directory"
	echo "		build.bat -? /? --help                 Shows this help message"
	echo ""
	echo "Notes:"
	echo "      After building, you may need to configure LD_LIBRARY_PATH to bin/* to run"
	echo "		Uses `debug` for debug binaries"
	echo "		Uses `debug_coverage` for coverage enabling"
	echo "		Uses `GCC` for specifying GCC executable"
	echo "		Uses `OBJCOPY` for modifying GCC objects"
	echo "		Uses `AR` for specifying AR executable"
	echo "		Uses `MAKE` for specifying MAKE executable"
	echo "		Uses `GCC_VER` for specifying lua gcc version for building lua dlls"
	echo ""
	echo "Configure above notes with set:"
	echo "		debug, debug_coverage, GCC, OBJCOPY, AR, MAKE, GCC_VER"
	echo ""
	echo "	Specify luajit if you want to use luajit"
	echo ""
}

# On failure found
function failure() {
	echo "An error has occured!"
	exit 1
}


# Basic help switches
if [ -z "$1" ]; then
	echo -i "No arguments specified.\n"
	help_message
	exit 1
fi

if [ "$1" = "/?" ]; then
	help_message
	exit 0
fi

if [ "$1" = "-?" ]; then
	help_message
	exit 0
fi

if [ "$1" = "--help" ]; then
	help_message
	exit 0
fi


# --------------------------------------------------------------------


# Cleans the build directory
if [ "$1" = "clean" ]; then
	echo "Cleaning build directory..."
	rm include/*.h
	rm dll/*.so
	rm dll/*.so.*
	rm obj/*.o
	rm lib/*.a
	rm -r -d bin/*
	
	echo "Done."
	exit 0
fi


# --------------------------------------------------------------------


# Installs to a directory
if [ "$1" = "install" ]; then
	if [ -z "$2" ]; then
		echo "Please specify where to install to."
		failure
	fi
	
	echo Installing to directory $2...
	if [ ! -d "$2" ]; then
		echo "Please create the destination folder first."
		failure
	fi
	
	cp -r bin/Release/* $2
	
	echo "Done."
	exit 0
fi


# --------------------------------------------------------------------


# GCC setup
if [ "$debug" = "0" ]; then
	attrib="-std=gnu11 -Wall -O2"
	root="bin/Release"
else
	attrib="-std=gnu11 -Wall -g -O0"
	root="bin/Debug"
	if [ "$debug_coverage" = "1" ]; then
		attrib="$attrib -coverage"
	fi
fi



objdir=obj
libdir=lib
resdir=res
rootdir=root
dlldir=dll
srcdir=src
incdir=include

dirs="-L$srcdir -L$libdir -L$dlldir -I$srcdir -I$incdir"


# --------------------------------------------------------------------


if [ ! -d "lua-all" ]; then
	echo "Please run prereqs.sh to get lua-all"
	exit 1
fi

if [ ! -d "luajit-2.0" ]; then
	echo "Please run prereqs.sh to get luajit"
	exit 1
fi


# --------------------------------------------------------------------


build_luajit () {
	echo "Building luajit..."
	
	pushd luajit-2.0/src
		if [ ! -f "libluajit.so" ]; then
			$MAKE -j5
		else
			echo "libluajit.so already cached."
		fi
		
		echo "Installing..."
		cp lua.h ../../include
		cp luaconf.h ../../include
		cp lualib.h ../../include
		cp lauxlib.h ../../include
		cp luajit.h ../../include
		ln libluajit.so libluajit-5.1.so.2
		cp libluajit.so ../../dll
		cp libluajit-5.1.so.2 ../../dll
	popd
	
	echo "Finished installing luajit."
}


build_lua () {
	echo "Building $1..."
	
	pushd lua-all/$1
		if [ ! -f "$1.so" ]; then
			echo "Compiling $1..."
			$GCC -std=$GCC_VER -g0 -O2 -Wall -fPIC $luaverdef -DLUA_USE_POSIX -c *.c
			
			rm lua.o
			$OBJCOPY --redefine-sym main=luac_main luac.o
			
			echo "Linking $1..."
			$GCC -std=$GCC_VER -g0 -O2 -Wall -fPIC -shared -Wl,-E -o $1.so *.o -lm -ldl
			
			echo "Archiving $1..."
			$AR rcu lib$1.a *.o
		else
			echo "$1.so already cached."
		fi
		
		echo "Installing..."
		cp lua.h ../../include
		cp luaconf.h ../../include
		cp lualib.h ../../include
		cp lauxlib.h ../../include
		cp $1.so ../../dll
	popd
	
	echo "Finished installing $1."
}

build_install () {
	echo "Installing $1..."
	mv *.o $objdir
	if [ "$1" = "luajit" ]; then
		cp -r $dlldir/* $root
		mkdir $root/jit
	else
		cp $dlldir/$1.so $root/dll
	fi
	mv lc*.so $root

	echo "Finished installing $1."
}

build_package () {
	if [ "$1" = "luajit" ]; then
		luaverdef="-DLUA_JIT_51"
		luaverout="$dlldir/libluajit.so"
	else
		luaverout="$dlldir/$1.so"
	fi
	
	echo "Compiling luaw driver package $1..."
	$GCC $attrib $dirs -fPIC -DLC_LD_DLL $luaverdef -c $srcdir/ldata.c $srcdir/jitsupport.c
	
	echo "Linking luaw driver package $1..."
	$GCC $attrib $dirs -fPIC -shared -Wl,-E -o lc$1.so ldata.o jitsupport.o $luaverout
	
	echo "Finished building driver package $1."
}

build_driver () {
	echo "Compiling luaw driver..."
	$GCC $attrib $dirs -DDEFAULT_LUA=\"lc$1.so\" -c $srcdir/luadriver.c
	
	echo "Linking luaw driver $1..."
	$GCC $attrib $dirs -o luaw luadriver.o -ldl
	
	build_package $1
	
	if [ "$debug" = "0" ]; then
		echo "Stripping..."
		strip --strip-all luaw
	fi

	echo "Finished building driver $1."
}


# --------------------------------------------------------------------


if [ "$1" = "driver" ]; then

	echo "Cleaning workspace..."
	# Resets bin
	if [ -d "$root" ]; then
		rm -r --one-file-system -d $root
	fi
	
	# Resets dll
	rm -r $dlldir/*.so
	
	# Output build structure
	mkdir -p $root/res
	mkdir -p $root/dll
	mkdir -p $root/lang
	
	# Build dependencies
	if [ "$2" = "luajit" ]; then
		build_luajit
		if [ ! -d "$root/jit" ]; then
			mkdir -p $root/jit
			cp -r luajit-2.0/src/jit/* $root/jit
		fi
	else
		if [ ! -d "lua-all/$2" ]; then
			echo Not a valid lua version!
			failure
		fi
		build_lua $2
	fi
	
	# Build driver
	build_driver $2
	chmod +x luaw

	# Build install
	mv luaw $root
	cp -r $resdir/* $root/res
	cp -r $rootdir/* $root 1>/dev/null 2>/dev/null
	build_install $2
	
	echo "Finished."
	exit 0
fi


# --------------------------------------------------------------------


if [ "$1" = "package" ]; then
	
	# Force driver to be built
	if [ ! -f "$root/luaw" ]; then
		echo "Please build the driver first."
		exit 1
	fi
	
	echo "Cleaning workspace..."
	# Resets dll
	rm -r $dlldir/*.so
	
	if [ "$2" = "luajit" ]; then
		build_luajit
		if [ ! -d "$root/jit" ]; then
			mkdir -p $root/jit
			cp -r luajit-2.0/src/jit/* $root/jit
		fi
	else
		if [ ! -d "lua-all/$2" ]; then
			echo Not a valid lua version!
			failure
		fi
		build_lua $2
	fi
	
	build_package $2
	build_install $2
	
	echo "Finished."
	exit 0
fi

