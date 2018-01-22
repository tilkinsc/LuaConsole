#!/usr/bin/env bash

debug=1
luaverdef=-DLUA_JIT_51
luaver=lua51

if [[ $debug -eq 0 ]]; then
	attrib="-std=gnu99 -s -Wall -O2"
	root=bin/Release
else
	attrib="-std=gnu99 -Wall -g -O0"
	root=bin/Debug
fi


objdir=obj
libdir=lib
resdir=res
rootdir=root
dlldir=dll
srcdir=src
incdir=include

dirs="-L$srcdir -L$libdir -L$dlldir -I$srcdir -I$incdir"

	
if [ -d $root ]; then
	rm -r --one-file-system -r -d $root
fi
mkdir -p $root
mkdir -p $root/res


# Compile everything w/ additions
gcc $attrib $dirs $luaverdef -c $srcdir/consolew.c $srcdir/darr.c
gcc $attrib $dirs $luaverdef -Wl,-E -fPIC -c $srcdir/additions.c

# Create luaadd.so
gcc $attrib $dirs -shared -Wl,-E -fPIC -o luaadd.so additions.o $dlldir/$luaver.so

# Link luaw
gcc $attrib $dirs -o luaw consolew.o darr.o $dlldir/$luaver.so -lm -ldl


chmod +x luaw


mv *.so $root 1>/dev/null 2>/dev/null
mv *.o $objdir 1>/dev/null 2>/dev/null
mv *.a $objdir 1>/dev/null 2>/dev/null
mv luaw $root 1>/dev/null 2>/dev/null
cp -r $resdir/* $root/res 1>/dev/null 2>/dev/null
cp -r $dlldir/* $root 1>/dev/null 2>/dev/null
cp -r $rootdir/* $root 1>/dev/null 2>/dev/null

if [[ $debug -eq 1 ]]; then
	strip --strip-all $root/luaw
fi

echo Done.

