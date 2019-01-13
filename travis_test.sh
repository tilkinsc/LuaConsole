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
./prereqs.sh

# Building
echo "> BUILDING"
export debug=1
export debug_coverage=1
./build.sh driver luajit
./build.sh package lua-5.3.5
./build.sh package lua-5.2.4
./build.sh package lua-5.1.5

# Testing
echo "> TESTING"
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
pushd bin/Debug
	echo "Test 1"
	./luaw -e "print('Everything went okay')"
	
	echo "Test 2"
	./luaw -w luajit -e "print('Everything went okay')"
	
	echo "Test 3"
	./luaw -w lua-5.3.5 -e "print('Everything went okay')"
	
	echo "Test 4"
	./luaw -w lua-5.2.4 -e "print('Everything went okay')"
	
	echo "Test 5"
	./luaw -w lua-5.1.5 -e "print('Everything went okay')"
popd

# Code coverage
gcov *.gc*
bash <(curl -s https://codecov.io/bash)



exit 0
