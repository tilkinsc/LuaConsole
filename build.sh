#!/usr/bin/env bash

# Set up variables as you need
debug=1

luaverdef=-DLUA_JIT_51
luaver=-lluajit-5.1
luainc=.
#luainc=/usr/local/include
#luainc is for external include directory only
#If its in ./include, keep luainc set to .


if [[ $debug -eq 0 ]]; then
	attrib="-std=gnu99 -s -Wall -O2"
	root=bin/Release
else
	attrib="-std=gnu99 -coverage -Wall -g -O0"
	root=bin/Debug
fi


# Paths that are in use, shouldn't have to modify below
objdir=obj
libdir=lib
resdir=res
rootdir=root
dlldir=dll
srcdir=src
incdir=include

dirs="-L$srcdir -L$libdir -L$dlldir -I$srcdir -I$incdir -I$luainc"


# Ensure bin resulting path
if [ -d $root ]; then
	rm -r --one-file-system -r -d $root
fi
mkdir -p $root
mkdir -p $root/res


# Compile everything w/ additions
gcc $attrib $dirs $luaverdef  -c $srcdir/consolew.c $srcdir/darr.c
if [ $? -ne 0 ]; then exit 1; fi
gcc $attrib $dirs $luaverdef -Wl,-E -fPIC -c $srcdir/additions.c
if [ $? -ne 0 ]; then exit 1; fi

# Create luaadd.so
gcc $attrib $dirs -shared -Wl,-E -fPIC -o luaadd.so additions.o $luaver
if [ $? -ne 0 ]; then exit 1; fi

# Link luaw
gcc $attrib $dirs -o luaw consolew.o darr.o $luaver -lm -ldl
if [ $? -ne 0 ]; then exit 1; fi


# Make luaw executable
chmod +x luaw


# Migrate necessary files into resulting path
mv *.so $root 1>/dev/null 2>/dev/null
mv *.o $objdir 1>/dev/null 2>/dev/null
mv *.a $objdir 1>/dev/null 2>/dev/null
mv luaw $root 1>/dev/null 2>/dev/null
cp -r $resdir/* $root/res 1>/dev/null 2>/dev/null
cp -r $dlldir/* $root 1>/dev/null 2>/dev/null
cp -r $rootdir/* $root 1>/dev/null 2>/dev/null


# Strip exe of useless information that lingered
if [[ ! $debug -eq 0 ]]; then
	strip --strip-all $root/luaw
fi


echo Done.

