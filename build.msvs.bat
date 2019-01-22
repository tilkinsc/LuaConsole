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

REM MSVS Build File

setlocal
	
	REM Default env vars
	IF NOT DEFINED debug			set debug=0
	
	REM Basic help switches
	IF [] == [%1] (
		echo No arguments specified.
		echo.
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
	
	
	REM --------------------------------------------------------------------
	
	
	REM Cleans the build directory...
	IF [clean] == [%1] (
		echo Cleaning build directory...
		del include\*.h
		del dll\*.dll
		del dll\*.lib
		del dll\*.exp
		del obj\*.obj
		rmdir /S /Q bin\*
		
		echo Done.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	REM Installs to a directory
	IF [install] == [%1] (
		IF [] == [%2] (
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
	
	
	IF NOT EXIST "lua-all" (
		echo Please run prereqs.bat to get lua-all
		goto failure
	)
	
	IF NOT EXIST "luajit-2.0" (
		echo Please run prereqs.bat to get luajit
		goto failure
	)
	
	
	REM --------------------------------------------------------------------
	
	
	REM MSVS setup
	IF [%debug%] EQU [0] (
		set attrib=/O2
		set root=bin\Release
	) ELSE (
		set attrib=/Od
		set root=bin\Debug
	)
	
	set objdir=obj
	set libdir=lib
	set resdir=res
	set rootdir=root
	set dlldir=dll
	set srcdir=src
	set incdir=include
	
	set dirs=/I%srcdir% /I%incdir%
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [driver] (
		echo Cleaning workspace...
		REM Resets bin
		IF EXIST "%root%" rmdir /S /Q %root%
		
		REM Resets dll
		del %dlldir%\*.dll
		del %dlldir%\*.lib
		del %dlldir%\*.exp
		
		REM Output build structure
		mkdir %root%\res
		
		REM Build dependencies
		IF [%2] == [luajit] (
			call :build_luajit
		) ELSE (
			IF NOT EXIST "lua-all\%2" (
				echo Not a valid lua version!
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
			echo Please build the driver first.
			goto failure
		)
		
		echo Cleaning workspace...
		REM Resets dll
		del %dlldir%\*.dll
		del %dlldir%\*.lib
		del %dlldir%\*.exp
		
		IF [%2] == [luajit] (
			call :build_luajit
		) ELSE (
			IF NOT EXIST "lua-all\%2" (
				echo Not a valid lua version!
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
		echo Building luajit...
		
		pushd luajit-2.0\src
			IF NOT EXIST "lua51.dll" (
				msvcbuild.bat
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
			xcopy /Y lua51.lib	..\..\dll
			xcopy /Y lua51.exp	..\..\dll
		popd
		
		echo Finished installing luajit.
		goto :EOF
	endlocal
	
	:build_lua
	setlocal
		echo "Building %1..."
		
		pushd lua-all\%1
			IF NOT EXIST "*.lib" (
				echo Building %1...
				
				IF EXIST "lua.c"	del lua.c
				REM IF EXIST "luac.c"	del luac.c
				
				cl.exe /O2 /D_USRDLL /D_WINDLL /DLUA_BUILD_AS_DLL *.c /link /DLL /EXPORT:luac_main=main /OUT:%1.dll
			) ELSE (
				echo %1 already cached.
			)
			
			echo Installing...
			xcopy /Y lua.h		..\..\include
			xcopy /Y luaconf.h	..\..\include
			xcopy /Y lualib.h	..\..\include
			xcopy /Y lauxlib.h	..\..\include
			xcopy /Y %1.dll		..\..\dll
			xcopy /Y %1.lib		..\..\dll
			xcopy /Y %1.exp		..\..\dll
		popd
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_install
	setlocal
		move /Y *.obj %objdir%
		IF [%1] == [luajit] (
			copy /Y %dlldir%\lua51.dll %root%
			copy /Y %dlldir%\lua51.lib %root%
		) ELSE (
			copy /Y %dlldir%\%1.dll %root%
			copy /Y %dlldir%\%1.lib %root%
		)
		copy lc%1.dll %dlldir%
		move lc%1.dll %root%
		move lc%1.lib %dlldir%
		move lc%1.exp %dlldir%
		
		
		echo Finished installing %1.
		goto :EOF
	endlocal
	
	:build_package
	setlocal
		echo Building luaw driver package %1...
		IF [%1] == [luajit] (
			set luaverdef=/DLUA_JIT_51
			set luaverout=%dlldir%\lua51.lib
		) ELSE (
			set luaverout=%dlldir%\%1.lib
		)
		
		cl.exe %attrib% %dirs% %luaverdef% /D_USRDLL /D_WINDLL /DLC_LD_DLL %srcdir%\ldata.c %srcdir%\jitsupport.c %luaverout% /link /DLL /OUT:lc%1.dll
		
		goto :EOF
	endlocal
	
	:build_driver
	setlocal
		echo Building luaw driver...
		
		cl.exe %attrib% %dirs% /DDEFAULT_LUA=\"lc%1.dll\" %srcdir%\luadriver.c /link /OUT:luaw.exe
		
		call :build_package %1
		
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



