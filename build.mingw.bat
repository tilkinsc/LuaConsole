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
	
	
	REM - Basic Variables --------------------------------------------------
	
	
	IF NOT DEFINED debug			set debug=0
	IF NOT DEFINED debug_coverage	set debug_coverage=0
	IF NOT DEFINED GCC				set GCC=gcc
	IF NOT DEFINED OBJCOPY			set OBJCOPY=objcopy
	IF NOT DEFINED AR				set AR=ar
	IF NOT DEFINED MAKE				set MAKE=make
	IF NOT DEFINED GCC_VER			set GCC_VER=gnu99
	
	
	REM - Basic Switches ---------------------------------------------------
	
	
	IF [] == [%1] (
		goto help
	)
	IF [/?] == [%1] (
		goto help
	)
	IF [-?] == [%1] (
		goto help
	)
	IF [--help] == [%1] (
		goto help
	)
	
	
	REM - Basic Dependencies Checking --------------------------------------
	
	
	REM -- TODO: add in executable checking
	
	
	REM - Basic Innerworking Variables -------------------------------------
	
	
	set "CWD=%cd%"
	
	
	REM - Basic Cleaner ----------------------------------------------------
	
	
	IF [clean] == [%1] (
		echo Cleaning build directory %CWD% ...
		echo Remove %CWD%\include\*.h
		del %CWD%\include\*.h
		echo Remove %CWD%\dll\*.dll
		del %CWD%\dll\*.dll
		echo Remove %CWD%\obj\*.o
		del %CWD%\obj\*.o
		echo Remove %CWD%\lib\*.a
		del %CWD%\lib\*.a
		rmdir /S /Q %CWD%\bin
		
		echo Done.
		exit /b 0
	)
	
	
	REM - Basic Installer --------------------------------------------------
	
	
	IF [install] == [%1] (
		IF [] == [%2] (
			echo please specify where to install to
			goto failure
		)
		IF NOT EXIST "%2" (
			echo please create the destination folder first
			goto failure
		)
		
		echo Installing to directory %2 ...
		xcopy /Y %CWD%\bin\Release\* %2
		
		echo Done.
		exit /b 0
	)
	
	
	REM - Basic GCC Setup --------------------------------------------------
	
	
	IF [0] EQU [%debug%] (
		set attrib=-std=gnu11 -Wall -O2
		set root=%CWD%\bin\Release
	) ELSE (
		set attrib=-std=gnu11 -Wall -g -O0
		set root=%CWD%\bin\Debug
		IF [1] EQU [%debug_coverage%]	set "attrib=%attrib% -coverage"
	)
	
	set objdir=%CWD%\obj
	set libdir=%CWD%\lib
	set resdir=%CWD%\res
	set rootdir=%CWD%\root
	set dlldir=%CWD%\dll
	set srcdir=%CWD%\src
	set incdir=%CWD%\include
	
	set "dirs=-L%srcdir% -L%libdir% -L%dlldir% -I%srcdir% -I%incdir%"
	
	
	REM - Basic Cache Checking ---------------------------------------------
	
	
	IF NOT EXIST "%CWD%\lua-all" (
		echo please run prereqs.bat download to get lua-all
		goto failure
	)
	
	IF NOT EXIST "%CWD%\luajit-2.0" (
		echo please run prereqs.bat download to get luajit
		goto failure
	)
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [driver] (
		echo Cleaning workspace %CWD% ...
		
		REM Resets bin
		IF EXIST "%root%" rmdir /S /Q %root%
		
		REM Resets dll
		del %dlldir%\*.dll
		
		REM Create build structure
		mkdir %root%\res
		mkdir %root%\dll
		mkdir %root%\lang
		
		REM Build dependencies
		IF [%2] == [luajit] (
			call :build_luajit
			IF NOT EXIST "%root%\jit" (
				mkdir %root%\jit
				xcopy /E /Y %CWD%\luajit-2.0\src\jit\* %root%\jit
			)
		) ELSE (
			IF NOT EXIST "%CWD%\lua-all\%2" (
				echo supplied argument %2 is not a valid lua version in lua-all
				goto failure
			)
			call :build_lua %2
		)
		
		REM Build driver
		call :build_driver %2
		
		REM Build install
		move /Y luaw.exe %root%\luaw.exe
		xcopy /E /Y %resdir%\*	%root%\res
		xcopy /E /Y %rootdir%\*	%root%
		call :build_install %2
		
		echo Finished.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [package] (
		
		REM Force driver to be built
		IF NOT EXIST "%root%\luaw.exe" (
			echo please run build.mingw.bat driver lua-5.x.x first
			goto failure
		)
		
		echo Cleaning workspace...
		
		REM Resets dll
		del %dlldir%\*.dll
		
		IF [%2] == [luajit] (
			call :build_luajit
			IF NOT EXIST "%root%\jit" (
				mkdir %root%\jit
				xcopy /E /Y %CWD%\luajit-2.0\src\jit\* %root%\jit
			)
		) ELSE (
			IF NOT EXIST "%CWD%\lua-all\%2" (
				echo supplied argument %2 is not a valid lua version in lua-all
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
	
	
	echo This shouldn't be reached!
	goto failure
	
	
	REM --------------------------------------------------------------------
	
	
	:build_luajit
	setlocal
		echo Locally building luajit %CWD%\luajit-2.0 ...
			
		pushd %CWD%\luajit-2.0\src
			IF EXIST "mingw_libluajit.dll" (
				echo libluajit.dll already cached.
			) ELSE (
				%MAKE% -j%NUMBER_OF_PROCESSORS%
				move lua51.dll	mingw_libluajit.dll
			)
			
			echo Locally installing luajit %CWD% ...
			copy /Y lua.h			%incdir%\lua.h
			copy /Y luaconf.h		%incdir%\luaconf.h
			copy /Y lualib.h		%incdir%\lualib.h
			copy /Y lauxlib.h		%incdir%\lauxlib.h
			copy /Y luajit.h		%incdir%\luajit.h
			copy /Y mingw_libluajit.dll	%dlldir%\libluajit.dll
		popd
		
		echo Finished locally building / installing luajit.
		goto :EOF
	endlocal
	
	:build_lua
	setlocal
		echo Locally building lua %CWD%\lua-all\%1 ...
		
		pushd %CWD%\lua-all\%1
			IF EXIST "mingw_lib%1.dll" (
				echo lib%1.dll already cached.
			) ELSE (
				echo Compiling %1 ...
				%GCC% -std=%GCC_VER% -I. -g0 -O2 -Wall -c *.c
				
				del lua.o
				%OBJCOPY% --redefine-sym "main=luac_main" luac.o
				
				echo Linking lib%1.dll ...
				%GCC% -std=%GCC_VER% -L. -Wl,--require-defined,luac_main -g0 -O2 -Wall -shared -o lib%1.dll *.o
				
				move lib%1.dll	mingw_lib%1.dll
			)
			
			echo Locally installing %CWD% ...
			copy /Y lua.h		%incdir%\lua.h
			copy /Y luaconf.h	%incdir%\luaconf.h
			copy /Y lualib.h	%incdir%\lualib.h
			copy /Y lauxlib.h	%incdir%\lauxlib.h
			copy /Y mingw_lib%1.dll	%dlldir%\lib%1.dll
		popd
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_install
	setlocal
		echo Migrating %1 to %root%...
		
		move /Y *.o %objdir%
		IF [luajit] == [%1] (
			copy /Y %dlldir%\libluajit.dll %root%\libluajit.dll
		) ELSE (
			copy /Y %dlldir%\lib%1.dll %root%\lib%1.dll
		)
		move liblc%1.dll %root%
		
		echo Finished migrating %1 to %root%.
		goto :EOF
	endlocal
	
	:build_package
	setlocal
		IF [%1] == [luajit] (
			set luaverdef=-DLUA_JIT_51
			set luaverout=-lluajit
		) ELSE (
			set luaverout=-l%1
		)
		
		echo Compiling luaw driver package %1...
		%gcc% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\ldata.c %srcdir%\jitsupport.c
		
		echo Linking luaw driver package liblc%1.dll...
		%GCC% %attrib% %dirs% -shared -o liblc%1.dll ldata.o jitsupport.o %luaverout%
		
		echo Finished building driver package %1.
		goto :EOF
	endlocal
	
	:build_driver
	setlocal
		echo Compiling luaw driver (using %1)...
		%GCC% %attrib% %dirs% -D__USE_MINGW_ANSI_STDIO=1 -DDEFAULT_LUA=\"liblc%1.dll\" -c %srcdir%\luadriver.c
		
		echo Linking luaw driver...
		%GCC% %attrib% %dirs% -o luaw.exe luadriver.o
		
		echo Building default lua package %1...
		call :build_package %1
		
		IF [0] EQU [%debug%] (
			echo Stripping driver...
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
	echo     build driver lua-x.x.x          Builds the driver with a default package
	echo     build package lua-x.x.x         Creates packages for the driver
	echo     build clean                     Cleans the environment of built files
	echo     build install [directory]       Installs to a pre-created directory
	echo     build -? /? --help              Shows this help message
	echo.
	echo build and package accepts:
	echo    luajit, lua-5.1, lua-5.1.5, lua-5.2.0, etc
	echo.
	echo Listens to these variables:
	echo    debug, debug_coverage, GCC, OBJCOPY, AR, MAKE, GCC_VER
	echo.
	echo    debug          - 0, 1               Default: 0
	echo    debug_coverage - 0, 1               Default: 0
	echo    GCC            - gcc binary         Default: gcc
	echo    OBJCOPY        - objcopy binary     Default: objcopy
	echo    AR             - ar binary          Default: ar
	echo    MAKE           - make binary        Default: make
	echo    GCC_VER        - stdlib version     Default: gnu99
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	pause
	exit /b 1
	
