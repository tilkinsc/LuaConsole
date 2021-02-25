#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2017-2021 Cody Tilkins
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
printf "> PREREQS\n"
if [[ ! "$(ls -A $HOME/cistore/lua-all)" ]]; then
	printf "Not cached. Downloading...\n"
	
	./prereqs.sh download
	
	cp -r lua-all $HOME/cistore
	cp -r luajit-2.0 $HOME/cistore
	
	printf "Travis-CI cache created.\n"
else
	printf "Cached. Migrating...\n"
	cp -r $HOME/cistore/lua-all lua-all
	cp -r $HOME/cistore/luajit-2.0 luajit-2.0
fi


# Building
printf "> BUILDING\n"
export debug=1
export debug_coverage=1
./build.linux.sh driver luajit
./build.linux.sh package lua-5.4.2
./build.linux.sh package lua-5.3.5
./build.linux.sh package lua-5.2.4
./build.linux.sh package lua-5.1.5

# Testing
printf "> TESTING\n"
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
printf "LD_LIBRARY_PATH=$LD_LIBRARY_PATH\n"
pushd bin/Debug
	printf "Test 1\n"
	./luaw -e "print('Everything went okay')"
	
	# Code coverage
	printf "CodeCoverage snapshot\n"
	gcov *.gc*
	bash <(curl -s https://codecov.io/bash)
	
	printf "Test 2\n"
	./luaw -w luajit -e "print('Everything went okay')"
	
	printf "Test 3\n"
	./luaw -w lua-5.3.5 -e "print('Everything went okay')"
	
	printf "Test 4\n"
	./luaw -w lua-5.2.4 -e "print('Everything went okay')"
	
	printf "Test 5\n"
	./luaw -w lua-5.1.5 -e "print('Everything went okay')"
	
	printf "Test 6\n"
	./luaw ./res/testing.lua -Dtest=5 -n a b c
	printf "Test 6 end\n"
	
	printf "Test 7\n"
	./luaw -b ./res/testing.lua ./testing.luac1
	./luaw ./testing.luac1 -Dtest=5 -n a b c
	printf "Test 7 end\n"
	
	printf "Test 8\n"
	./luaw -w luajit -c -o ./testing.luac2 ./res/testing.lua
	./luaw -w luajit -ltesting.luac2 -Dtest=5 -n a b c
	printf "Test 8 end\n"
	
	printf "Test 9\n"
	./luaw -w lua-5.4.2 -c -o ./testing.luac3 ./res/testing.lua
	./luaw -w lua-5.4.2 -ltesting.luac3 -Dtest=5 -n a b c
	printf "Test 9 end\n"
	
	printf "Test 10\n"
	./luaw -w lua-5.3.5 -c -o ./testing.luac4 ./res/testing.lua
	./luaw -w lua-5.3.5 -ltesting.luac4 -Dtest=5 -n a b c
	printf "Test 10 end\n"
	
	printf "Test 11\n"
	./luaw -w lua-5.2.4 -c -o ./testing.luac5 ./res/testing.lua
	./luaw -w lua-5.2.4 -ltesting.luac5 -Dtest=5 -n a b c
	printf "Test 11 end\n"
	
	printf "Test 12\n"
	./luaw -w lua-5.1.5 -c -o ./testing.luac6 ./res/testing.lua
	./luaw -w lua-5.1.5 -ltesting.luac6 -Dtest=5 -n a b c
	printf "Test 12 end\n"
	
popd

printf "Testing complete.\n"

# Update cache if needed
cp -f -r -u lua-all $HOME/cistore
cp -f -r -u luajit-2.0 $HOME/cistore


exit 0
