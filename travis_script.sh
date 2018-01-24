#!/usr/bin/env bash

echo Managing dependancies...

echo " # luajit-2.0"
pushd $HOME/luajit-2.0
	if [ ! "$(ls -A $HOME/luajit-2.0)" ]; then
		git clone http://luajit.org/git/luajit-2.0.git $HOME/luajit-2.0
		make -j 4
	fi
	# TODO: migrate stuff needed elsewhere to prevent downloading a lot, instead of make install
	sudo make install
	sudo ldconfig
popd

echo Done managing dependancies.
