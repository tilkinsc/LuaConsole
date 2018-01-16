#!/usr/bin/env bash

root=../bin/Release
objdir=../obj
resdir=../res
rootdir=../root
luaver=lua51
luaverdef=-DLUA_JIT_51
dlldir=../dll

cd src
	
	if [ -d $root ]; then
		rm -r --one-file-system -r -d $root
	fi
	mkdir -p $root
	mkdir -p $root/res
	
	
	# Compile everything release w/ additions
	gcc -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude $luaverdef -c consolew.c additions.c darr.c
	
	# Create luaadd.so luaadd.so.a
	gcc -s -shared -Wall -Wl,-E -fPIC -O2 -g0 -L. -Ldll -Iinclude $luaverdef -o luaadd.so additions.o -l$luaver.so
	
	# Link luaw
	gcc -s -Wall -Wl,-E -O2 -g0 -L. -Llib -Ldll -Iinclude -o luaw consolew.o darr.o -lluaadd.so -l$luaver.so -lm -ldl
	
	
	chmod +x luaw
	
	
	mv *.so $root
	mv *.o $objdir
	mv *.a $objdir
	mv luaw $root
	cp -r $resdir/* $root/res
	cp -r $dlldir/* $root
	cp -r $rootdir/* $root
	
	
	strip --strip-all luaw
	
	echo Done.
	
cd ..

