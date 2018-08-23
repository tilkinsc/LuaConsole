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



debug=0
debug_coverage=0
no_additions=0

# -DLUA_JIT_51 -DLUA_51 -DLUA_52 -DLUA_53
luaverdef=-DLUA_JIT_51
luaver=-lluajit-5.1

# luainc is for an external non-system-std lua include directory only
# if its in ./include, keep luainc set to .
luainc=.


# --------------------------------------------------------------------


if [[ $debug -eq 0 ]]; then
	attrib="-std=gnu11 -s -Wall -O2"
	root=bin/Release
else
	attrib="-std=gnu11 -Wall -g -O0"
	root=bin/Debug
	if [ $debug_coverage -eq 1 ]; then
		attrib=$attrib -coverage
	fi
fi


objdir=obj
libdir=lib
resdir=res
rootdir=root
dlldir=dll
srcdir=src
incdir=include

dirs="-L$srcdir -L$libdir -L$dlldir -I$srcdir -I$incdir -I$luainc"


# Ensure bin && bin/res exists
if [ -d $root ]; then rm -r --one-file-system -d $root; fi
mkdir -p $root/res


# --------------------------------------------------------------------


echo Compiling luaw...
gcc $attrib $dirs $luaverdef -c $srcdir/consolew.c $srcdir/jitsupport.c $srcdir/darr.c
if [ $? -ne 0 ]; then exit 1; fi

echo Linking luaw...
gcc $attrib $dirs -o luaw consolew.o jitsupport.o darr.o $luaver -lm -ldl
if [ $? -ne 0 ]; then exit 1; fi
# Strip if not debug
if [ $debug -eq 1 ]; then
	strip --strip-all luaw
	if [ $? -ne 0 ]; then exit 1; fi
fi


if [ $no_additions -eq 0 ]; then
	echo Compiling additions...
	gcc $attrib $dirs $luaverdef -Wl,-E -fPIC -c $srcdir/additions.c
	if [ $? -ne 0 ]; then exit 1; fi
	echo Linking additions...
	gcc $attrib $dirs -shared -Wl,-E -fPIC -o luaadd.so additions.o $luaver
	if [ $? -ne 0 ]; then exit 1; fi
fi


# --------------------------------------------------------------------


# Make luaw executable
chmod +x luaw


# Migrate binaries
mv *.so $root 1>/dev/null 2>/dev/null
mv *.o $objdir 1>/dev/null 2>/dev/null
mv *.a $objdir 1>/dev/null 2>/dev/null
mv luaw $root 1>/dev/null 2>/dev/null
cp -r $resdir/* $root/res 1>/dev/null 2>/dev/null
cp -r $dlldir/* $root 1>/dev/null 2>/dev/null
cp -r $rootdir/* $root 1>/dev/null 2>/dev/null


echo Done.

