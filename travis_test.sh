#!/usr/bin/env bash


	
errors=0



if [ -d "./bin/Debug" ]; then
	./bin/Debug/luaw -lluaadd.so ./res/testing.lua -v -Tb -n a b c
	if [ $? -ne 0 ]; then
		echo Testing scenario 1 failed to complete.
		((errors++))
	else
		gcov *.gc*
		bash <(curl -s https://codecov.io/bash)
	fi
else
	export LUA_CPATH=./?.so;$LUA_CPATH
	./bin/Release/luaw -lluaadd.so ./res/testing.lua -v -Tb -n a b c
	if [ $? -ne 0 ]; then
		echo Testing scenario 1 failed to complete.
		((errors++))
	fi
fi




if [ $errors > 0 ]; then
	echo Exited with $errors errors!
	exit 1
fi
	

