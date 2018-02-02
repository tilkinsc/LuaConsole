REM MIT License
REM 
REM Copyright (c) 2017-2018 Cody Tilkins
REM 
REM Permission is hereby granted, free of charge, to any person obtaining a copy
REM of this software and associated documentation files (the "Software"), to deal
REM in the Software without restriction, including without limitation the rights
REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
REM copies of the Software, and to permit persons to whom the Software is
REM furnished to do so, subject to the following conditions:
REM 
REM The above copyright notice and this permission notice shall be included in all
REM copies or substantial portions of the Software.
REM 
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
REM SOFTWARE.

@echo off

echo ^>^>^> Cleaning bin
echo ^> bin\Debug
rmdir /S /Q bin\Debug
rmdir /S /Q bin\debug

echo ^> bin\Release
rmdir /S /Q bin\Release
rmdir /S /Q bin\release


echo ^>^>^> Cleaning obj
echo ^> *.o
del /Q *.o
del /Q obj\*.o
del /Q src\*.o
echo ^> *.a
del /Q *.a
del /Q obj\*.a
del /Q src\*.a
echo ^> *.dll
del /Q *.dll
del /Q obj\*.dll
del /Q src\*.dll

echo ^>^>^> Cleaning debug
echo ^> *.gcov
del /Q *.gcov
echo ^> *.gcda
del /Q *.gcda
echo ^> *.gcno
del /Q *.gcno

