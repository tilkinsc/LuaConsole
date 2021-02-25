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


# - Basic Variables --------------------------------------------------


[[ -z "${debug}" ]] &&			debug="0"
[[ -z "${debug_coverage}" ]] &&	debug_coverage="0"
[[ -z "${GCC}" ]] &&			GCC="gcc"
[[ -z "${OBJCOPY}" ]] &&		OBJCOPY="gobjcopy"
[[ -z "${AR}" ]] &&				AR="ar"
[[ -z "${MAKE}" ]] &&			MAKE="make"
[[ -z "${GCC_VER}" ]] &&		GCC_VER="gnu99"


# - Basic Functions --------------------------------------------------


error() {
	printf "\n\n$0 : ${2} : Error: ${1}\n" 1>&2
	exit 1
}

# TODO: translate, 'cat build.espanol.linux.help'
help_message() {
	printf """
Usage:

    build build lua-x.x.x           Builds the driver with a default package
    build package lua-x.x.x         Creates packages for the driver
    build clean                     Cleans the environment of built files
    build install {directory}       Installs to a pre-created directory
    build -? /? --help              Shows this help message
    
build and package accepts:
    luajit, lua-5.1, lua-5.1.5, lua-5.2.0, etc
    
Listens to these variables:
    debug, debug_coverage, GCC, OBJCOPY, AR, MAKE, GCC_VER
    
    debug          - 0, 1               Default: 0
    debug_coverage - 0, 1               Default: 0
    GCC            - gcc binary         Default: gcc
    OBJCOPY        - gobjcopy binary    Default: gobjcopy
    AR             - ar binary          Default: ar
    MAKE           - make binary        Default: make
    GCC_VER        - stdlib version     Default: gnu99
    
Notes:
    After building, you may need to configure LD_LIBRARY_PATH to bin/Release/* to test
    
"""
	exit 0
}


# - Basic Switches ---------------------------------------------------


[[ -z "${1}" || "${1}" == "/?" || "${1}" == "-?" || "${1}" == "--help" ]] && help_message


# - Basic Dependencies Checking --------------------------------------


which "${GCC}" || error "GCC not found suggested: apt install gcc build-essential" $LINENO
which "${OBJCOPY}" || error "OBJCOPY not found suggested: apt install gcc build-essential" $LINENO
which "${AR}" || error "AR not found suggested: apt install gcc build-essential" $LINENO
which "${MAKE}" || error "MAKE not found suggested: apt install gcc build-essential" $LINENO


# - Basic Innerworking Variables -------------------------------------


CWD="$(pwd)"


# - Basic Cleaner ----------------------------------------------------


if [[ "${1}" == "clean" ]]; then
	printf "Cleaning build directory (${CWD})...\n"
	printf "Remove ${CWD}/include/*.h\n"
	rm -f -I ${CWD}/include/*.h
	printf "Remove ${CWD}/dll/*.so\n"
	rm -f -I ${CWD}/dll/*.so*
	printf "Remove ${CWD}/obj/*.o\n"
	rm -f -I ${CWD}/obj/*.o
	printf "Remove ${CWD}/lib/*.a\n"
	rm -f -I ${CWD}/lib/*.a
	printf "Remove ${CWD}/bin\n"
	rm -f -I -r -d ${CWD}/bin
	
	printf "Done.\n"
	exit 0
fi


# - Basic Installer --------------------------------------------------


if [[ "${1}" == "install" ]]; then
	[[ -z "${2}" ]] && error "please specify where to install to" $LINENO
	[[ -d "${2}" ]] || error "please create the destination folder first" $LINENO
	
	printf "Installing to directory (${2})...\n"
	cp -r -i ${CWD}/bin/Release/* "${2}"
	
	printf "Done.\n"
	exit 0
fi


# - Basic GCC Setup --------------------------------------------------


if [[ "${debug}" == "0" ]]; then
	attrib="-std=gnu11 -Wall -O2"
	root="${CWD}/bin/Release"
else
	attrib="-std=gnu11 -Wall -g -O0"
	root="${CWD}/bin/Debug"
	[[ "${debug_coverage}" == "1" ]] && attrib="${attrib} -coverage"
fi

objdir="${CWD}/obj"
libdir="${CWD}/lib"
resdir="${CWD}/res"
rootdir="${CWD}/root"
dlldir="${CWD}/dll"
srcdir="${CWD}/src"
incdir="${CWD}/include"

dirs="-L${srcdir} -L${libdir} -L${dlldir} -I${srcdir} -I${incdir}"


# - Basic Cache Checking ---------------------------------------------


[[ -d "${CWD}/lua-all" ]] || error "please run 'prereqs.sh download' to get lua-all" $LINENO
[[ -d "${CWD}/luajit-2.0" ]] || error "please run prereqs.sh downliad' to get luajit" $LINENO


# --------------------------------------------------------------------


build_luajit() {
	printf "Locally building luajit (${CWD}/luajit-2.0)...\n"
	
	pushd "${CWD}/luajit-2.0/src"
		if [[ -f "libluajit.so" ]]; then
			printf "libluajit.so already cached\n"
		else
			$MAKE "-j$(nproc)"
		fi
		
		printf "Locally installing luajit (${CWD})...\n"
		cp lua.h "${incdir}"
		cp luaconf.h "${incdir}"
		cp lualib.h "${incdir}"
		cp lauxlib.h "${incdir}"
		cp luajit.h "${incdir}"
		ln libluajit.so libluajit-5.1.so.2
		cp libluajit.so "${dlldir}"
		cp libluajit-5.1.so.2 "${dlldir}"
	popd
	
	printf "Finished locally building & installing luajit.\n"
}


build_lua() {
	printf "Locally building lua (${CWD}/lua-all/${1})...\n"
	
	pushd "${CWD}/lua-all/${1}"
		if [[ -f "lib${1}.so" ]]; then
			printf "lib${1}.so already cached\n"
		else
			printf "Compiling (${1})...\n"
			$GCC "-std=${GCC_VER}" -g0 -O2 -Wall -fPIC $luaverdef -DLUA_USE_POSIX -c *.c
			
			rm lua.o
			$OBJCOPY --redefine-sym "main=luac_main" luac.o
			
			printf "Linking (lib${1}.so)...\n"
			$GCC "-std=${GCC_VER}" -g0 -O2 -Wall -fPIC -shared -Wl,-E -o "lib${1}.so" *.o -lm -ldl
			
			printf "Archiving (lib${1}.a)...\n"
			$AR rcs "lib${1}.a" *.o
		fi
		
		printf "Locally installing (${CWD})...\n"
		cp lua.h "${incdir}"
		cp luaconf.h "${incdir}"
		cp lualib.h "${incdir}"
		cp lauxlib.h "${incdir}"
		cp "lib${1}.so" "${dlldir}"
	popd
	
	printf "Finished locally building & installing ${1}.\n"
}

# TODO: very misleading
build_install() {
	printf "Migrating ${1} to ${root}...\n"
	
	mv *.o "${objdir}"
	if [[ "${1}" == "luajit" ]]; then
		cp -r ${dlldir}/* "${root}"
	else
		cp "${dlldir}/lib${1}.so" "${root}"
	fi
	mv liblc*.so "${root}"

	printf "Finished migrating ${1} to ${root}.\n"
}

build_package() {
	if [[ "${1}" == "luajit" ]]; then
		luaverdef="-DLUA_JIT_51"
		luaverout="-lluajit"
	else
		luaverout="-l${1}"
	fi
	
	printf "Compiling luaw driver package ${1}...\n"
	$GCC $attrib $dirs -fPIC -DLC_LD_DLL $luaverdef -c "${srcdir}/ldata.c" "${srcdir}/jitsupport.c"
	
	printf "Linking luaw driver package liblc${1}.so...\n"
	$GCC $attrib $dirs -fPIC -shared -Wl,-E -o "liblc${1}.so" ldata.o jitsupport.o "${luaverout}"
	
	printf "Finished building driver package ${1}.\n"
}

build_driver() {
	printf "Compiling luaw driver...\n"
	$GCC $attrib $dirs "-DDEFAULT_LUA=\"liblc${1}.so\"" -c "${srcdir}/luadriver.c"
	
	printf "Linking luaw driver ${1}...\n"
	$GCC $attrib $dirs -o luaw luadriver.o -ldl
	
	printf "Building default lua package ${1}...\n"
	build_package "${1}"
	
	if [[ "${debug}" == "0" ]]; then
		printf "Stripping driver...\n"
		strip --strip-all luaw
	fi

	printf "Finished building driver ${1}.\n"
}


# --------------------------------------------------------------------


if [[ "$1" == "driver" ]]; then
	printf "Cleaning workspace (${CWD})...\n"
	
	# Resets bin
	[[ -d "${root}" ]] && rm -r --one-file-system -d "${root}"
	
	# Resets dll
	rm -r ${dlldir}/*.so
	
	# Create build structure
	mkdir -p "${resdir}"
	mkdir -p "${dlldir}"
	mkdir -p "${root}/lang"
	
	# Build dependencies
	if [[ "${2}" == "luajit" ]]; then
		build_luajit
		if [[ ! -d "${root}/jit" ]]; then
			mkdir -p "${root}/jit"
			cp -r $CWD/luajit-2.0/src/jit/* "${root}/jit"
		fi
	else
		[[ -d "${CWD}/lua-all/${2}" ]] || error "supplied argument ${2} is not a valid lua version in lua-all" $LINENO
		build_lua "${2}"
	fi
	
	# Build driver
	build_driver "${2}"
	chmod +x luaw
	
	# Build install
	mv luaw "${root}"
	cp -r ${resdir} "${root}/res"
	cp -r ${rootdir}/* "${root}"
	build_install "${2}"
	
	printf "Finished.\n"
	exit 0
fi


# --------------------------------------------------------------------


if [[ "$1" == "package" ]]; then
	
	# Force driver to be built
	[[ -f "${root}/luaw" ]] || error "please run ${0} driver lua-5.x.x first" $LINENO
	
	printf "Cleaning workspace...\n"
	
	# Resets dll
	rm -r ${dlldir}/*.so
	
	if [[ "${2}" == "luajit" ]]; then
		build_luajit
		if [[ ! -d "${root}/jit" ]]; then
			mkdir -p "${root}/jit"
			cp -r $CWD/luajit-2.0/src/jit/* "${root}/jit"
		fi
	else
		[[ -d "${CWD}/lua-all/${2}" ]] || error "supplied argument ${2} is not a valid lua version in lua-all" $LINENO
		build_lua "${2}"
	fi
	
	# Build package and install
	build_package "${2}"
	build_install "${2}"
	
	printf "Finished.\n"
	exit 0
fi

error "This shouldn't be reached!\n" $LINENO

