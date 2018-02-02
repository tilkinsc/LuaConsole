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

echo '>>> Cleaning bin'
echo '> bin\Debug'
rm --one-file-system -f -r -d bin\Debug
rm --one-file-system -f -r -d bin\debug

echo '> bin\Release'
rm --one-file-system -f -r -d bin\Release
rm --one-file-system -f -r -d bin\release


echo '>>> Cleaning obj'
echo '> *.o'
rm --one-file-system *.o
rm --one-file-system obj\*.o
rm --one-file-system src\*.o
echo '> *.a'
rm --one-file-system *.a
rm --one-file-system obj\*.a
rm --one-file-system src\*.a
echo '> *.dll'
rm --one-file-system *.dll
rm --one-file-system obj\*.dll
rm --one-file-system src\*.dll

echo '>>> Cleaning Debug'
echo '> *.gcov'
rm --one-file-system *.gcov
echo '> *.gcda'
rm --one-file-system *.gcda
echo '> *.gcno'
rm --one-file-system *.gcno

