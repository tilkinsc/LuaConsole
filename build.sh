#!/usr/bin/env bash

root=../bin/release
objdir=../obj
resdir=../res

cd src
	
	if [ -d $root ]; then
		rm -r --one-file-system -r -d $root
	fi
	mkdir -p $root
	mkdir -p $root/res
	
	
	# Compile everything release w/ additions
	gcc -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -DLUACON_ADDITIONS -c console.c consolew.c additions.c darr.c
	
	# Create luaadd.so luaadd.so.a
	gcc -s -shared -Wl,-E,--out-implib,libluaadd.so.a -fPIC -O2 -g0 -Wall -L. -Ldll -Iinclude -o luaadd.so additions.o -llua53.so
	
	# Link luaw
	gcc -s -Wl,-E -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -o lua console.o darr.o -lluaadd.so -llua53.so -lm
	
	# Link lua
	gcc -s -Wl,-E -Wall -O2 -g0 -o luaw consolew.o darr.o -lluaadd.so -llua53.so -lm
	
	
	chmod +x lua
	chmod +x luaw
	
	
	mv *.so $root
	mv *.o $objdir
	mv *.a $objdir
	mv lua $root
	mv luaw $root
	cp -r $resdir/* $root/res
	
	
	strip --strip-all lua
	strip --strip-all luaw
	
cd ..

