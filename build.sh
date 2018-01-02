#!/usr/bin/env bash

root=../bin/release
objdir=../obj
resdir=../res

cd src

# Compile everything release w/ additions
gcc -std=gnu99 -Wall -O2 -g0 -DLUACON_ADDITIONS -c console.c consolew.c additions.c

# Link luaw
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua_add console.o additions.o -Wl,-E -ldl -lm -llua

# Link lua
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw_add consolew.o additions.o -Wl,-E -ldl -lm -llua

# Compile everything release w/o additions
gcc -std=gnu99 -Wall -O2 -g0 -c console.c consolew.c

# Link luaw
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua console.o -Wl,-E -ldl -lm -llua

# Link lua
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw consolew.o -Wl,-E -ldl -lm -llua

if [ -d $root ]; then
	rm -r --one-file-system -r -d $root
fi
mkdir -p $root
mkdir -p $root/res

chmod +x lua
chmod +x luaw
chmod +x lua_add
chmod +x luaw_add

mv *.o $objdir
mv lua $root
mv luaw $root
mv lua_add $root
mv luaw_add $root
cp -r $resdir/* $root/res

cd $root

strip --strip-all lua_add
strip --strip-all luaw_add
strip --strip-all lua
strip --strip-all luaw

