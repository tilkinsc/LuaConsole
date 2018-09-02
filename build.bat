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
	
	@REM luainc is for an external lua headers location
	@REM if its in ./include, keep luainc set to `.`, else i.e. `C:\git\luajit-2.0\src` might be an option
	if NOT DEFINED luainc			set luainc=.
	
	
	@REM --------------------------------------------------------------------
	
	
	if [%1] EQU [LUA51] (
		set luaverdef= 
		set luaver=lua51
	)
	if [%1] EQU [LUA52] (
		set luaverdef= 
		set luaver=lua52
	)
	if [%1] EQU [LUA53] (
		set luaverdef= 
		set luaver=lua53
	)
	if [%1] EQU [LUAJIT] (
		set luaverdef=-DLUA_JIT_51
		set luaver=lua51
	)
	
	@REM These are defaults, defaults to luajit
	if NOT DEFINED debug 			set debug=0
	if NOT DEFINED debug_coverage	set debug_coverage=0
	if NOT DEFINED no_additions		set no_additions=0
	if NOT DEFINED luaverdef		set luaverdef=-DLUA_JIT_51
	if NOT DEFINED luaver			set luaver=lua51
	
	
	@REM --------------------------------------------------------------------
	
	
	if %debug% EQU 0 (
		set attrib=-std=gnu11 -s -Wall -O2
		set root=bin\Release
	) else (
		set attrib=-std=gnu11 -Wall -g -O0
		set root=bin\Debug
		if %debug_coverage% EQU 1 set attrib=%attrib% -coverage
	)
	
	set objdir=obj
	set libdir=lib
	set resdir=res
	set rootdir=root
	set dlldir=dll
	set srcdir=src
	set incdir=include
	
	set dirs=-L%srcdir% -L%libdir% -L%dlldir% -I%srcdir% -I%incdir% -I%luainc%
	
	
	@REM Ensure bin && bin\res exists
	if EXIST %root% ( rmdir /S /Q %root% )
	mkdir %root%\res
	
	
	@REM --------------------------------------------------------------------
	
	
	echo Compiling luaw...
	gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -c %srcdir%\consolew.c %srcdir%\jitsupport.c %srcdir%\darr.c
	if %errorlevel% NEQ 0 exit /b 1
	
	echo Linking luaw...
	gcc %attrib% %dirs% -o luaw.exe consolew.o jitsupport.o darr.o %dlldir%\%luaver%.dll
	if %errorlevel% NEQ 0 exit /b 1
	@REM Strip if not debug
	if %debug% EQU 0 (
		strip --strip-all luaw.exe
		if %errorlevel% NEQ 0 exit /b 1
	)
	
	
	if %no_additions% EQU 0 (
		echo Compiling additions...
		gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -c %srcdir%\additions.c
		if %errorlevel% NEQ 0 exit /b 1
		echo Linking additions..
		gcc %attrib% %dirs% -shared -o luaadd.dll additions.o %dlldir%\%luaver%.dll
		if %errorlevel% NEQ 0 exit /b 1
	)
	
	
	@REM --------------------------------------------------------------------
	
	
	@REM Migrate binaries
	move /Y *.dll		%root%		1>nul	2>nul
	move /Y *.o			%objdir%	1>nul	2>nul
	move /Y *.a			%objdir%	1>nul	2>nul
	move /Y *.exe		%root%		1>nul	2>nul
	copy /Y %resdir%\*	%root%\res	1>nul	2>nul
	copy /Y %dlldir%\*	%root%		1>nul	2>nul
	copy /Y %rootdir%\*	%root%		1>nul	2>nul
	
endlocal

echo Done.

exit /b

