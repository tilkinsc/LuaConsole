#!/usr/bin/env bash

pushd bin/Debug

	errors=0


	./luaw ./res/testing.lua -v -Tb -n a b c
	if [ $? -ne 0 ]; then
		echo Testing scenario 1 failed to complete.
		((errors++))
	fi


	if [ $errors > 0 ]; then
		echo Exited with $errors errors!
		exit 1
	fi

popd
