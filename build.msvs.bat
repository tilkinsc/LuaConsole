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

REM MSVS Build File

setlocal
	
	
	REM - Basic Variables --------------------------------------------------
	
	
	IF NOT DEFINED debug			set debug=0
	
	
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
		echo Remove %CWD%\dll\*.lib
		del %CWD%\dll\*.lib
		echo Remove %CWD%\dll\*.exp
		del %CWD%\dll\*.exp
		echo Remove %CWD%\obj\*.obj
		del %CWD%\obj\*.obj
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
	
	
	REM - Basic MSVS Setup -------------------------------------------------
	
	
	IF [%debug%] EQU [0] (
		set attrib=/O2
		set root=%CWD%\bin\Release
	) ELSE (
		set attrib=/Od
		set root=%CWD%\bin\Debug
	)
	
	set objdir=%CWD%\obj
	set libdir=%CWD%\lib
	set resdir=%CWD%\res
	set rootdir=%CWD%\root
	set dlldir=%CWD%\dll
	set srcdir=%CWD%\src
	set incdir=%CWD%\include
	
	set dirs=/I%srcdir% /I%libdir% /I%incdir% /I%dlldir%
	
	
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
		del %dlldir%\*.dll %dlldir%\*.lib %dlldir%\*.exp
		
		REM Output build structure
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
		del %dlldir%\*.dll %dlldir%\*.lib %dlldir%\*.exp
		
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
		
		echo Finished
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
			IF NOT EXIST "msvs_lua51.lib" (
				call msvcbuild.bat
			) ELSE (
				echo msvs_lua51.lib already cached.
			)
			
			echo Locally installing luajit %CWD% ...
			move lua51.lib msvs_lua51.lib
			move lua51.dll msvs_lua51.dll
			move lua51.exp msvs_lua51.exp
			xcopy /Y lua.h			%incdir%
			xcopy /Y luaconf.h		%incdir%
			xcopy /Y lualib.h		%incdir%
			xcopy /Y lauxlib.h		%incdir%
			xcopy /Y luajit.h		%incdir%
			xcopy /Y msvs_lua51.dll	%dlldir%\libluajit.dll
			xcopy /Y msvs_lua51.lib	%dlldir%\libluajit.lib
			xcopy /Y msvs_lua51.exp	%dlldir%\libluajit.exp
		popd
		
		echo Finished locally building / installing luajit.
		goto :EOF
	endlocal
	
	:build_lua
	setlocal
		echo Locally building lua %CWD%\lua-all\%1 ...
		
		pushd %CWD%\lua-all\%1
			IF EXIST "msvs_lib%1.lib" (
				echo msvs_lib%1.lib already cached.
			) ELSE (
				echo Building %1 ...
				
				REM TODO: upright deleting lua.c is bad
				IF EXIST "lua.c"	del lua.c
				
				REM TODO: I don't know if LUA_BUILD_AS_DLL is necessary
				cl.exe /O2 /D_USRDLL /D_WINDLL /DLUA_BUILD_AS_DLL *.c /link /DLL /EXPORT:luac_main=main /OUT:lib%1.dll
			)
			
			echo Locally installing %CWD% ...
			move lib%1.dll msvs_lib%1.dll
			move lib%1.lib msvs_lib%1.lib
			move lib%1.exp msvs_lib%1.exp
			xcopy /Y lua.h			%incdir%
			xcopy /Y luaconf.h		%incdir%
			xcopy /Y lualib.h		%incdir%
			xcopy /Y lauxlib.h		%incdir%
			xcopy /Y msvs_lib%1.dll	%dlldir%\lib%1.dll
			xcopy /Y msvs_lib%1.lib	%dlldir%\lib%1.lib
			xcopy /Y msvs_lib%1.exp	%dlldir%\lib%1.exp
		popd
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_install
	setlocal
		echo Migrating %1 to %root%...
		
		move /Y *.obj %objdir%
		IF [luajit] == [%1] (
			copy /Y %dlldir%\libluajit.dll %root%
			copy /Y %dlldir%\libluajit.lib %root%
		) ELSE (
			copy /Y %dlldir%\lib%1.dll %root%
			copy /Y %dlldir%\lib%1.lib %root%
		)
		move liblc%1.dll %root%
		move liblc%1.lib %dlldir%
		move liblc%1.exp %dlldir%
		
		echo Finished migrating %1 to %root%.
		goto :EOF
	endlocal
	
	:build_package
	setlocal
		IF [%1] == [luajit] (
			set luaverdef=/DLUA_JIT_51
			set luaverout=%dlldir%\libluajit.lib
		) ELSE (
			set luaverout=%dlldir%\lib%1.lib
		)
		
		echo Building luaw driver package %1...
		cl.exe %attrib% %dirs% %luaverdef% /D_USRDLL /D_WINDLL /DLC_LD_DLL %srcdir%\ldata.c %srcdir%\jitsupport.c %luaverout% /link /DLL /OUT:liblc%1.dll
		
		echo Finished building driver package %1.
		goto :EOF
	endlocal
	
	:build_driver
	setlocal
		echo Building luaw driver...
		
		cl.exe %attrib% %dirs% /DDEFAULT_LUA=\"liblc%1.dll\" %srcdir%\luadriver.c /link /OUT:luaw.exe
		
		echo Building default lua package %1...
		call :build_package %1
		
		echo Finished building driver %1.
		goto :EOF
	endlocal
	
endlocal


REM Simplex help message
:help
	echo Usage:
	echo.
	echo     build build lua-x.x.x           Builds the driver with a default package
	echo     build package lua-x.x.x         Creates packages for the driver
	echo     build clean                     Cleans the environment of built files
	echo     build install [directory]       Installs to a pre-created directory
	echo     build -? /? --help              Shows this help message
	echo.
	echo build and package accepts:
	echo    luajit, lua-5.1, lua-5.1.5, lua-5.2.0, etc
	echo.
	echo Listens to these variables:
	echo    debug
	echo.
	echo    debug          - 0, 1               Default: 0
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	pause
	exit /b 1

