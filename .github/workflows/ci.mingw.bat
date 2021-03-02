@REM MIT License
@REM 
@REM Copyright (c) 2017-2021 Cody Tilkins
@REM 
@REM Permission is hereby granted, free of charge, to any person obtaining a copy
@REM of this software and associated documentation files (the "Software"), to deal
@REM in the Software without restriction, including without limitation the rights
@REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@REM copies of the Software, and to permit persons to whom the Software is
@REM furnished to do so, subject to the following conditions:
@REM 
@REM The above copyright notice and this permission notice shall be included in all
@REM copies or substantial portions of the Software.
@REM 
@REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@REM SOFTWARE.

@echo off

setlocal
	
	REM Init
	echo ^> PREREQS
	set DLM=curl
	call prereqs.bat download
	
	
	REM Building
	echo ^> BUILDING
	set debug=1
	call build.mingw.bat driver lua-5.4.2
	call build.mingw.bat package luajit
	call build.mingw.bat package lua-5.3.6
	call build.mingw.bat package lua-5.2.4
	call build.mingw.bat package lua-5.1.5
	echo Building complete.
	
	dir bin\Debug
	
	
	REM Testing
	echo ^> TESTING
	pushd bin\Debug
		echo Test 1
		luaw -e "print('Everything went okay')"
		
		echo Test 2
		luaw -w luajit -e "print('Everything went okay')"
		
		echo Test 3
		luaw -w lua-5.3.6 -e "print('Everything went okay')"
		
		echo Test 4
		luaw -w lua-5.2.4 -e "print('Everything went okay')"
		
		echo Test 5
		luaw -w lua-5.1.5 -e "print('Everything went okay')"
		
		echo Test 6
		luaw res\testing.lua -Dtest=5 -n a b c
		echo Test 6 end
		
		echo Test 7
		luaw -b res\testing.lua testing.luac
		luaw testing.luac -Dtest=5 -n a b c
		echo Test 7 end
		
		echo Test 8
		luaw -w luajit -c -o testing.luac "res\testing.lua"
		luaw -w luajit -ltesting.luac -Dtest=5 -n a b c
		echo Test 8 end
		
		echo Test 9
		luaw -w lua-5.4.2 -c -o testing.luac "res\testing.lua"
		luaw -w lua-5.4.2 -ltesting.luac -Dtest=5 -n a b c
		echo Test 9 end
		
		echo Test 10
		luaw -w lua-5.3.6 -c -o testing.luac "res\testing.lua"
		luaw -w lua-5.3.6 -ltesting.luac -Dtest=5 -n a b c
		echo Test 10 end
		
		echo Test 11
		luaw -w lua-5.2.4 -c -o testing.luac "res\testing.lua"
		luaw -w lua-5.2.4 -ltesting.luac -Dtest=5 -n a b c
		echo Test 11 end
		
		echo Test 12
		luaw -w lua-5.1.5 -c -o testing.luac "res\testing.lua"
		luaw -w lua-5.1.5 -ltesting.luac -Dtest=5 -n a b c
		echo Test 12 end
		
		echo Testing complete.
	popd
	
endlocal


exit /b 0

