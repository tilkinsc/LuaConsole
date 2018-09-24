@REM MIT License
@REM 
@REM Copyright (c) 2017-2018 Cody Tilkins
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
	
	REM Basic switches
	if [] == [%1] (
		echo No arguments specified.
		echo.
		goto help
	)
	
	if [/?] == [%1] (
		goto help
	)
	if [-?] == [%1] (
		goto help
	)
	if [--help] == [%1] (
		goto help
	)
	
	if [] == [%2] (
		echo Not enough arguments supplied. Missing 2nd argument.
		echo.
		goto help
	)
	
	
	REM --------------------------------------------------------------------
	
	
	REM luainc is for an external lua headers location
	REM if its in ./include, keep luainc set to `.` for null, else i.e. `C:\git\luajit-2.0\src`
	IF NOT DEFINED luainc			set luainc=.
	
	REM These can be defaults, defaults to luajit
	IF NOT DEFINED debug 			set debug=0
	IF NOT DEFINED debug_coverage	set debug_coverage=0
	
	
	REM --------------------------------------------------------------------
	
	
	IF %debug% EQU 0 (
		set attrib=-std=gnu11 -Wall -O2
		set root=bin\Release
	) else (
		set attrib=-std=gnu11 -Wall -g -O0
		set root=bin\Debug
		IF %debug_coverage% EQU 1 set attrib=%attrib% -coverage
	)
	
	set objdir=obj
	set libdir=lib
	set resdir=res
	set rootdir=root
	set dlldir=dll
	set srcdir=src
	set incdir=include
	
	set dirs=-L%srcdir% -L%libdir% -L%dlldir% -I%srcdir% -I%incdir% -I%luainc%
	
	
	set arg1=%2
	set luaver=%arg1:~0,3%-%arg1:~3,1%.%arg1:~4,1%.%arg1:~5,1%
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [driver] (
		REM Ensure bin && bin\res exists
		IF EXIST %root% ( rmdir /S /Q %root% )
		mkdir %root%\res
		
		echo Building luaw driver and default package...
		
		call prereqs.bat switch %arg1%
		IF NOT EXIST "%luaver%" (
			echo No lua available! prereqs failed!
			exit /b 1
		)
		
		echo Compiling luaw driver...
		gcc %attrib% %dirs% -D__USE_MINGW_ANSI_STDIO=1 -DDEFAULT_LUA=\"lc%arg1%.dll\" -c %srcdir%\darr.c %srcdir%\luadriver.c
		IF %errorlevel% NEQ 0 exit /b 1
		
		echo Compiling default luaw as package %luaver%...
		gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\consolew.c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
		IF %errorlevel% NEQ 0 exit /b 1
		
		echo Linking luaw driver...
		gcc %attrib% %dirs% -o luaw.exe luadriver.o darr.o
		IF %errorlevel% NEQ 0 exit /b 1
		
		echo Linking default luaw as package %luaver%...
		gcc %attrib% %dirs% -shared -o lc%arg1%.dll consolew.o ldata.o jitsupport.o darr.o %dlldir%\%arg1%.dll
		IF %errorlevel% NEQ 0 exit /b 1
		
		REM Strip luaw driver if not debug
		IF %debug% EQU 0 (
			strip --strip-all luaw.exe
			IF %errorlevel% NEQ 0 exit /b 1
		)
		
		call :migrate
		
		exit /b 0
	)
	
	
	IF [%1] == [package] (
		echo Linking local luaw as %luaver%...
		
		call prereqs.bat switch %arg1%
		IF NOT EXIST "%luaver%" (
			echo No lua available! prereqs failed!
			exit /b 1
		)
		
		echo Compiling luaw as package %luaver%...
		gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\consolew.c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
		IF %errorlevel% NEQ 0 exit /b 1
		
		echo Linking luaw as package %luaver%...
		gcc %attrib% %dirs% -shared -o lc%arg1%.dll consolew.o ldata.o jitsupport.o darr.o %dlldir%\%arg1%.dll
		IF %errorlevel% NEQ 0 exit /b 1
		
		call :migrate
		
		exit /b 0
	)
	
	REM IF [%1] == [adds] (
		REM echo Compiling additions...
		REM gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -c %srcdir%\additions.c
		REM IF %errorlevel% NEQ 0 exit /b 1
		REM echo Linking additions...
		REM gcc %attrib% %dirs% -shared -o luaadd.dll additions.o %dlldir%\%luaver%.dll
		REM IF %errorlevel% NEQ 0 exit /b 1
	REM )
	
	
	REM --------------------------------------------------------------------
	
endlocal

exit /b 1



:migrate
	REM Migrate binaries
	move /Y *.dll		%root%		
	move /Y *.o			%objdir%	
	move /Y *.a			%objdir%	
	move /Y *.exe		%root%		
	copy /Y %resdir%\*	%root%\res	
	copy /Y %dlldir%\*	%root%		
	copy /Y %rootdir%\*	%root%		
	exit /b 0

:help
	REM Simplex help message
	echo Usage:
	echo.
	echo build.bat driver {luajit,lua515,lua535,...}
	echo build.bat package {all,luajit,lua515,lua535,...}
	echo.
	echo Note: Most lua versions supported, but must use 3 digit numbers.
	echo.
	exit /b 0

exit /b 1

