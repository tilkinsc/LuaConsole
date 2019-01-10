#!/usr/bin/env bash

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


# Default env vars
if [ -z $debug ]; then			debug=0; fi
if [ -z $debug_coverage ]; then	debug_coverage=0; fi
if [ -z $force_build ]; then		force_build=0; fi
if [ -z $GCC ]; then				GCC=0; fi
if [ -z $AR ]; then				AR=0; fi
if [ -z $MAKE ]; then				MAKE=0; fi
if [ -z $GCC_VER ]; then			GCC_VER=0; fi


function help_message() {
	echo Usage:
	echo \n
	echo		build.bat build lua-x.x.x              Builds the driver with a default package.
	echo		build.bat package lua-x.x.x            Creates packages for the driver.
	echo		build.bat clean                        Cleans the environment of built files.
	echo		build.bat install [directory]          Installs to a pre-created directory.
	echo		build.bat -? /? --help                 Shows this help message
	echo \n
	echo Notes:
	echo		Uses `debug` for debug binaries
	echo		Uses `debug_coverage` for coverage enabling
	echo		Uses `force_build` for forcing builds of packages
	echo		Uses `GCC` for specifying GCC executable
	echo		Uses `AR` for specifying AR executable
	echo		Uses `MAKE` for specifying MAKE executable
	echo		Uses `GCC_VER` for specifying lua gcc version for building lua dlls
	echo \n
	echo Configure above notes with set:
	echo		debug, debug_coverage, force_build, GCC, AR, MAKE, GCC_VER
	echo \n
	echo 	Specify luajit if you want to use luajit.
	echo \n
}

function failure() {
	echo An error has occured!
	exit 1
}


# Basic switches
if [ -z $1 ]; then
	echo "No arguments specified.\n"
	help_message
	exit 1
fi

if [ $1 -eq "/?" ]; then
	help_message
	exit 0
fi

if [ $1 -eq "-?" ]; then
	help_message
	exit 0
fi

if [ $1 -eq "--help" ]; then
	help_message
	exit 0
fi


# --------------------------------------------------------------------


# Cleans the build directory
if [ $1 -eq "clean" ]; then
	echo Cleaning build directory...
	rm include/*.h
	rm dll/*.so
	rm obj/*.o
	rm lib/*.a
	rm -r -d bin/*
	
	echo Done.
	exit 0
fi


# --------------------------------------------------------------------


# Installs to a directory
if [ $1 -eq "install" ]; then
	if [ $2 -eq "" ]; then
		echo Please specify where to install to.
		failure
	fi
	
	echo Installing to directory $2...
	if [ ! -d $2 ]; then
		echo Please create the destination folder first.
		failure
	fi
	
	cp bin\Release\* $2
	
	echo DOne.
	exit 0
fi


# --------------------------------------------------------------------


# GCC setup
if [ $debug -eq 0 ]; then
	attrib="-std=gnu11 -Wall -O2"
	root="bin/Release"
else
	attrib="-std=gnu11 -Wall -g -O0"
	root="bin/Debug"
	if [ $debug_coverage -eq 1 ]; then
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
	echo Please run prereqs.sh to get lua-all
	exit 1
fi

if [ ! -d "luajit-2.0" ]; then
	echo Please run prereqs.sh to get luajit
	exit 1
fi


# --------------------------------------------------------------------


if [ $1 -eq "driver" ]; then
	# Ensure bin && bin/res exists
	
	echo Cleaning bin...
	# Resets bin\res
	if [ -d $root ]; then
		rm -r --one-file-system -d $root
	fi
	mkdir $root\res
	
	if [ $2 -eq "luajit" ]; then
		echo Building luajit...
		
		pushd luajit-2.0/src
			if [ ! -f "lua51.dll" ]; then
				$MAKE -j5
			else
				if [ $force_build -eq 1 ]; then
					$MAKE -j5
				fi
			fi
			
			echo Installing...
			
			cp lua.h ../../include
			cp luaconf.h ../../include
			cp lualib.h ../../include
			cp lauxlib.h ../../include
			cp luajit.h ../../include
			cp lua51.dll ../../dll
		popd
		
		echo Finished building and linking luajit.
	else
		echo Building $2...
		
		pushd lua-all/$2
			if [ ! -f "*.dll" ]; then
				echo Compiling...
				$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra $lua_cflags -DLUA_BUILD_AS_DLL -c *.c
				
				rm lua.o
				rm luac.o
				
				echo Linking...
				$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -shared -o $2.so *.o
				
				echo Archiving...
				$AR rcu lib$2.a *.o
			else
				if [ $force_build -eq 1 ]; then
					echo Compiling...
					$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra $lua_cflags -DLUA_BUILD_AS_DLL -c *.c
					
					rm lua.o
					rm luac.o
					
					echo Linking...
					$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -shared -o $2.so *.o
					
					echo Archiving...
					$AR rcu lib$2.a *.o
				fi
			fi
			
			echo Installing...
			cp lua.h ../../include
			cp luaconf.h ../../include
			cp lualib.h ../../include
			cp lauxlib.h ../../include
			cp luajit.h ../../include
			cp lua51.dll ../../dll
		popd
		
		echo Finished building and linking $2.
	fi
	
	if [ $2 -eq "luajit" ]; then
		echo Compiling luaw driver...
		$GCC $attrib $dirs -DDEFAULT_LUA=\"lc$2.so\" -c $srcdir/darr.c $srcdir/luadriver.c
		
		echo Compiling default luaw driver package $2...
		$GCC $attrib $dirs $luaverdef -Wl,-E -fPIC -DLC_LD_DLL -DLUA_JIT_51 -c $srcdir/ldata.o $srcdir/jitsupport.c $srcdir/darr.c
		
		echo Linking luaw driver...
		$GCC $attrib $dirs -o luaw luadriver.o darr.o
		
		echo Linking default luaw driver package $2...
		$GCC $attrib $dirs -shared -Wl,-E -fPIC -o lc$2.so ldata.o jitsupport.o darr.o $dlldir/lua51.so
	else
		echo Compiling luaw driver...
		$GCC $attrib $dirs -DDEFAULT_LUA=\"lc$2.so\" -c $srcdir/darr.c $srcdir/luadriver.c
		
		echo Compiling default luaw driver package $2...
		$GCC $attrib $dirs $luaverdef -Wl,-E -fPIC -DLC_LD_DLL -c $srcdir/ldata.o $srcdir/jitsupport.c $srcdir/darr.c
		
		echo Linking luaw driver...
		$GCC $attrib $dirs -o luaw luadriver.o darr.o
		
		echo Linking default luaw driver package $2...
		$GCC $attrib $dirs -shared -Wl,-E -fPIC -o lc$2.so ldata.o jitsupport.o darr.o $dlldir/$2.so
	fi
	
	# Strip luaw driver if not debug
	echo Stripping...
	if [ $debug -eq 0 ]; then
		strip --strip-all luaw
	fi
	
	chmod +x luaw
	
	# Migrate binaries
	mv *.dll $root
	mv *.o $objdir
	mv *.a $libdir
	mv luaw $root
	cp -r $resdir/*		$root/res
	cp -r $dlldir/*		$root
	cp -r $rootdir/*	$root
	
	echo Finished.
	exit 0
fi


# --------------------------------------------------------------------


if [ $1 -eq "package" ]; then
	if [ $2 -eq "luajit" ]; then
		echo Building luajit...
		
		pushd luajit-2.0/src
			if [ ! -f "lua51.dll" ]; then
				$MAKE -j5
			else
				if [ $force_build -eq 1 ]; then
					$MAKE -j5
				fi
			fi
			
			echo Installing...
			
			cp lua.h ../../include
			cp luaconf.h ../../include
			cp lualib.h ../../include
			cp lauxlib.h ../../include
			cp luajit.h ../../include
			cp lua51.dll ../../dll
		popd
		
		echo Finished building and linking luajit.
	else
		echo Building $2...
		
		pushd lua-all/$2
			if [ ! -f "*.dll" ]; then
				echo Compiling...
				$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -Wl,-E -fPIC $lua_cflags -DLUA_BUILD_AS_DLL -c *.c
				
				rm lua.o
				rm luac.o
				
				echo Linking...
				$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -shared -Wl,-E -fPIC -o $2.so *.o
				
				echo Archiving...
				$AR rcu lib$2.a *.o
			else
				if [ $force_build -eq 1 ]; then
					echo Compiling...
					$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -Wl,-E -fPIC $lua_cflags -DLUA_BUILD_AS_DLL -c *.c
					
					rm lua.o
					rm luac.o
					
					echo Linking...
					$GCC -std=$GCC_VER -g0 -O2 -Wall -Wextra -shared -Wl,-E -fPIC -o $2.so *.o
					
					echo Archiving...
					$AR rcu lib$2.a *.o
				fi
			fi
			
			echo Installing...
			cp lua.h ../../include
			cp luaconf.h ../../include
			cp lualib.h ../../include
			cp lauxlib.h ../../include
			cp luajit.h ../../include
			cp lua51.dll ../../dll
		popd
		
		echo Finished building nad linking $2.
	fi
	
	echo Creating local luaw package as $2...
	
	if [ $2 -eq "luajit" ]; then
		echo Compiling luaw package $2...
		$GCC $attrib $dirs $luaverdef -Wl,-E -fPIC -DLC_LD_DLL -DLUA_JIT_51 -c $srcdir/ldata.c $srcdir/jitsupport.c $srcdir/darr.c
		
		echo Linking luaw package $2...
		$GCC $attrib $dirs -shared -Wl,-E -fPIC -o lc$2.so ldata.o jitsupport.o darr.o $dlldir/lua51.so
	else
		echo Compiling luaw package $2...
		$GCC $attrib $dirs $luaverdef -Wl,-E -fPIC -c $srcdir/ldata.c $srcdir/jitsupport.c $srcdir/darr.c
		
		echo Linking luaw package $2...
		$GCC $attrib $dirs -shared -Wl,-E -fPIC -o lc$2.so ldata.o jitsupport.o darr.o $dlldir/$2.so
	fi
	
	echo Finished building and linking $2.
	
	# Migrate binaries
	mv *.dll $root
	mv *.o $objdir
	mv *.a $libdir
	cp -r $resdir/*		$root/res
	cp -r $dlldir/*		$root
	cp -r $rootdir/*	$root
	
	echo Finished.
	exit 0
fi

