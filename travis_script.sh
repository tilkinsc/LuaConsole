#!/usr/bin/env bash

echo Managing dependancies...

if [ ! "$(ls -A $HOME/luajit-2.0)" ]; then
	git clone http://luajit.org/git/luajit-2.0.git $HOME/luajit-2.0
	pushd $HOME/luajit-2.0
		make -j 4
	popd
fi
mkdir ./include/luajit51
cp $HOME/luajit-2.0/src/*.h ./include/luajit51
cp $HOME/luajit-2.0/src/libluajit.so ./dll/libluajit.so


