#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2017-2019 Cody Tilkins
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

set -e

# Init
echo "> PREREQS"
if [ ! "$(ls -A $HOME/cistore/lua-all)" ]; then
	echo "Not cached. Downloading..."
	
	./prereqs.sh
	
	cp -r lua-all $HOME/cistore
	cp -r luajit-2.0 $HOME/cistore
	
	echo "Travis-CI cache created."
else
	echo "Cached. Migrating..."
	cp -r $HOME/cistore/lua-all lua-all
	cp -r $HOME/cistore/luajit-2.0 luajit-2.0
fi


# Building
echo "> BUILDING"
export debug=1
export debug_coverage=1
./build.linux.sh driver luajit
./build.linux.sh package lua-5.3.5
./build.linux.sh package lua-5.2.4
./build.linux.sh package lua-5.1.5

# Testing
echo "> TESTING"
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
pushd bin/Debug
	echo "Test 1"
	./luaw -e "print('Everything went okay')"
	
	# Code coverage
	gcov *.gc*
	bash <(curl -s https://codecov.io/bash)
	
	echo "Test 2"
	./luaw -w luajit -e "print('Everything went okay')"
	
	echo "Test 3"
	./luaw -w lua-5.3.5 -e "print('Everything went okay')"
	
	echo "Test 4"
	./luaw -w lua-5.2.4 -e "print('Everything went okay')"
	
	echo "Test 5"
	./luaw -w lua-5.1.5 -e "print('Everything went okay')"
	
	echo "Test 6"
	./luaw res/testing.lua -Dtest=5 -n a b c
	echo "Test 6 end"
	
	echo "Test 7"
	./luaw -b res/testing.lua testing.luac
	./luaw testing.luac -Dtest=5 -n a b c
	echo "Test 7 end"
	
	echo "Test 8"
	./luaw -w luajit -c -o testing.luac "res/testing.lua"
	./luaw -w luajit -ltesting.luac -Dtest=5 -n a b c
	echo "Test 8 end"
	
	echo "Test 9"
	./luaw -w lua-5.3.5 -c -o testing.luac "res/testing.lua"
	./luaw -w lua-5.3.5 -ltesting.luac -Dtest=5 -n a b c
	echo "Test 9 end"
	
	echo "Test 10"
	./luaw -w lua-5.2.4 -c -o testing.luac "res/testing.lua"
	./luaw -w lua-5.2.4 -ltesting.luac -Dtest=5 -n a b c
	echo "Test 10 end"
	
	echo "Test 11"
	./luaw -w lua-5.1.5 -c -o testing.luac "res/testing.lua"
	./luaw -w lua-5.1.5 -ltesting.luac -Dtest=5 -n a b c
	echo "Test 11 end"
	
popd


# Update cache if needed
cp -f -r -u lua-all $HOME/cistore
cp -f -r -u luajit-2.0 $HOME/cistore


exit 0
