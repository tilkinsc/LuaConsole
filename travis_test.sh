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

	
errors=0

debug=bin/Debug
release=bin/Release

if [ -d "./bin/Debug" ]; then
	export LUA_CPATH="./$debug/?.so;$LUA_CPATH"
	./$debug/luaw ./res/testing.lua -lluaadd.so -Tb -n a b c
	if [ $? -ne 0 ]; then
		echo Testing scenario 1 failed to complete.
		((errors++))
	else
		gcov *.gc*
		bash <(curl -s https://codecov.io/bash)
	fi
else
	export LUA_CPATH="./$release/?.so;$LUA_CPATH"
	./$release/luaw ./res/testing.lua -lluaadd.so -Tb -n a b c
	if [ $? -ne 0 ]; then
		echo Testing scenario 1 failed to complete.
		((errors++))
	fi
fi




if [ $errors > 0 ]; then
	echo Exited with $errors errors!
	exit 1
fi
	

