@REM MIT License
@REM 
@REM Copyright (c) 2017-2019 Cody Tilkins
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
	
	REM Default env vars
	IF NOT DEFINED debug			set debug=0
	IF NOT DEFINED debug_coverage	set debug_coverage=0
	IF NOT DEFINED GCC				set GCC=gcc
	IF NOT DEFINED AR				set AR=ar
	IF NOT DEFINED MAKE				set MAKE=make
	IF NOT DEFINED GCC_VER			set GCC_VER=gnu99
	
	
	REM Basic help switches
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
	
	
	REM --------------------------------------------------------------------
	
	
	REM Cleans the build directory
	IF [clean] == [%1] (
		echo Cleaning build directory...
		del include\*.h
		del dll\*.dll
		del obj\*.o
		del lib\*.a
		rmdir /S /Q bin\Release
		
		echo Done.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	REM Installs to a directory
	if [install] == [%1] (
		if [] == [%2] (
			echo Please specify where to install to.
			goto failure
		)
		
		echo Installing to directory %2...
		IF NOT EXIST "%2" (
			echo Please create the destination folder first.
			goto failure
		)
		
		xcopy /Y bin\Release\* %2
		
		echo Done.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	REM GCC setup
	IF [%debug%] EQU [0] (
		set attrib=-std=gnu11 -Wall -O2
		set root=bin\Release
	) else (
		set attrib=-std=gnu11 -Wall -g -O0
		set root=bin\Debug
		IF %debug_coverage% EQU 1	set attrib=%attrib% -coverage
	)
	
	set objdir=obj
	set libdir=lib
	set resdir=res
	set rootdir=root
	set dlldir=dll
	set srcdir=src
	set incdir=include
	
	set dirs=-L%srcdir% -L%libdir% -L%dlldir% -I%srcdir% -I%incdir%
	
	
	REM --------------------------------------------------------------------
	
	
	IF NOT EXIST "lua-all" (
		echo Please run prereqs.bat to get lua-all
		goto failure
	)
	
	IF NOT EXIST "luajit-2.0" (
		echo Please run prereqs.bat to get luajit
		goto failure
	)
	
	
	REM --------------------------------------------------------------------
	
	IF [%1] == [driver] (
		echo Cleaning workspace...
		REM Resets bin
		IF EXIST %root% rmdir /S /Q %root%
		
		REM Resets dll
		del %dlldir%\*.dll
		
		REM Output build structure
		mkdir %root%\res
		
		REM Build dependencies
		IF [%2] == [luajit] (
			call :build_luajit
		) ELSE (
			IF NOT EXIST "lua-all/%2" (
				echo Not a valid lua version!
				goto failure
			)
			call :build_lua %2
		)
		
		REM Build driver
		call :build_driver %2
		
		REM Build install
		move /Y luaw.exe %root%\luaw.exe
		copy /Y %resdir%\*	%root%\res
		echo wrap 1
		copy /Y %rootdir%\*	%root%
		echo wrap 1 eof
		call :build_install %2
		
		echo Finished.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [package] (
		
		REM Force driver to be built
		IF NOT EXIST %root%/luaw.exe (
			echo Please build the driver first.
			exit /b 1
		)
		
		echo Cleaning workspace...
		REM Resets dll
		del %dlldir%\*.dll
		
		IF [%2] == [luajit] (
			call :build_luajit
		) ELSE (
			IF NOT EXIST "lua-all/%2" (
				echo Not a valid lua version!
				goto failure
			)
			call :build_lua %2
		)
		
		call :build_package %2
		call :build_install %2
		
		echo Finished.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	:build_luajit
	setlocal
		echo Building luajit...
			
		pushd luajit-2.0\src
			IF NOT EXIST "lua51.dll" (
				%MAKE% -j%NUMBER_OF_PROCESSORS%
			) ELSE (
				echo luajit already cached.
			)
			
			echo Installing...
			xcopy /Y lua.h		..\..\include
			xcopy /Y luaconf.h	..\..\include
			xcopy /Y lualib.h	..\..\include
			xcopy /Y lauxlib.h	..\..\include
			xcopy /Y luajit.h	..\..\include
			xcopy /Y lua51.dll	..\..\dll
		popd
		
		echo Finished installing luajit.
		goto :EOF
	endlocal
	
	:build_lua
	setlocal
		echo "Building %1..."
		
		pushd lua-all\%1
			IF NOT EXIST "*.dll" (
				echo Compiling %1...
				%GCC% -std=%GCC_VER% -g0 -O2 -Wall %luaverdef% -c *.c
				
				del lua.o
				del luac.o
				
				echo Linking %1...
				%GCC% -std=%GCC_VER% -g0 -O2 -Wall -shared -o %1.dll *.o
				
				echo Archiving %1...
				%AR% rcu lib%1.a *.o
			) ELSE (
				echo %1 already cached.
			)
			
			echo Installing...
			xcopy /Y lua.h			..\..\include
			xcopy /Y luaconf.h		..\..\include
			xcopy /Y lualib.h		..\..\include
			xcopy /Y lauxlib.h		..\..\include
			xcopy /Y %1.dll			..\..\dll
		popd
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_install
	setlocal
		move /Y *.o %objdir%
		IF [%1] == [luajit] (
			echo wrap 2
			copy /Y %dlldir%\lua51.dll %root%
			echo wrap 2 eof
		) ELSE (
			echo wrap 3
			copy /Y %dlldir%\%1.dll %root%
			echo wrap 3 eof
		)
		echo wrap 4
		move lc%1.dll %root%
		echo wrap 4 eof
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_package
	setlocal
		IF [%1] == [luajit] (
			set luaverdef=-DLUA_JIT_51
			set luaverout=%dlldir%/lua51.dll
		) ELSE (
			set luaverout=%dlldir%/%1.dll
		)
		
		echo Compiling luaw driver package %1...
		%gcc% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\ldata.c %srcdir%\jitsupport.c
		
		echo Linking luaw driver package %1...
		%GCC% %attrib% %dirs% -shared -o lc%1.dll ldata.o jitsupport.o %luaverout%
		
		goto :EOF
	endlocal
	
	:build_driver
	setlocal
		echo Compiling luaw driver...
		%GCC% %attrib% %dirs% -D__USE_MINGW_ANSI_STDIO=1 -DDEFAULT_LUA=\"lc%1.dll\" -c %srcdir%\luadriver.c
		
		echo Linking luaw driver...
		%GCC% %attrib% %dirs% -o luaw.exe luadriver.o
		
		call :build_package %1
		
		IF %debug% EQU 0 (
			echo Stripping...
			strip --strip-all luaw.exe
		)
		
		echo Finished building driver %1.
		goto :EOF
	endlocal
	
endlocal


REM Simplex help message
:help
	echo Usage:
	echo.
	echo		build.bat build lua-x.x.x              Builds the driver with a default package
	echo		build.bat package lua-x.x.x            Creates packages for the driver
	echo		build.bat clean                        Cleans the environment of built files
	echo		build.bat install [directory]          Installs to a pre-created directory
	echo		build.bat -? /? --help                 Shows this help message
	echo.
	echo Notes:
	echo		Uses `debug` for debug binaries
	echo		Uses `debug_coverage` for coverage enabling
	echo		Uses `GCC` for specifying GCC executable
	echo		Uses `AR` for specifying AR executable
	echo		Uses `MAKE` for specifying MAKE executable
	echo		Uses `GCC_VER` for specifying lua gcc version for building lua dlls
	echo.
	echo Configure above notes with set:
	echo		debug, debug_coverage, GCC, AR, MAKE, GCC_VER
	echo.
	echo 	Specify luajit if you want to use luajit
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	pause
	exit /b 1

:end
