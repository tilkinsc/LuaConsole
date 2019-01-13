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
	IF NOT DEFINED force_build		set no_build=0
	
	IF NOT DEFINED GCC				set GCC=gcc
	IF NOT DEFINED AR				set AR=ar
	IF NOT DEFINED MAKE				set MAKE=make
	
	IF NOT DEFINED GCC_VER			set GCC_VER=gnu99
	
	
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
		
		echo Cleaning bin...
		REM Resets bin\res
		IF EXIST %root% ( rmdir /S /Q %root% )
		mkdir %root%\res
		
		IF [%2] == [luajit] (
			echo Building luajit...
			
			pushd luajit-2.0\src
				IF NOT EXIST "lua51.dll" (
					%MAKE% -j%NUMBER_OF_PROCESSORS%
				) ELSE (
					IF [%force_build%] == [1] (
						%MAKE% -j%NUMBER_OF_PROCESSORS%
					)
				)
				echo Installing...
				xcopy /Y lua.h		..\..\include
				xcopy /Y luaconf.h	..\..\include
				xcopy /Y lualib.h	..\..\include
				xcopy /Y lauxlib.h	..\..\include
				xcopy /Y luajit.h	..\..\include
				xcopy /Y lua51.dll	..\..\dll
			popd
			
			echo Finished building and linking luajit.
		) ELSE (
			echo Building %2...
			
			pushd lua-all\%2
				IF NOT EXIST "*.dll" (
					echo Compiling...
					%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra %lua_cflags% -DLUA_BUILD_AS_DLL -c *.c
					
					del lua.o
					del luac.o
					
					echo Linking...
					%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra -shared -o %2.dll *.o
					
					echo Archiving...
					%AR% rcu lib%2.a *.o
				) ELSE (
					IF [%force_build%] == [1] (
						echo Compiling...
						%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra %lua_cflags% -DLUA_BUILD_AS_DLL -c *.c
						
						del lua.o
						del luac.o
						
						echo Linking...
						%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra -shared -o %2.dll *.o
						
						echo Archiving...
						%AR% rcu lib%2.a *.o
					)
				)
				
				echo Installing...
				xcopy /Y lua.h			..\..\include
				xcopy /Y luaconf.h		..\..\include
				xcopy /Y lualib.h		..\..\include
				xcopy /Y lauxlib.h		..\..\include
				xcopy /Y %2.dll			..\..\dll
				xcopy /Y lib%2.a		..\..\lib
			popd
			
			echo Finished building and linking %2.
		)
		
		if [%2] == [luajit] (
			echo Compiling luaw driver...
			%GCC% %attrib% %dirs% -D__USE_MINGW_ANSI_STDIO=1 -DDEFAULT_LUA=\"lc%2.dll\" -c %srcdir%\darr.c %srcdir%\luadriver.c
			
			echo Compiling default luaw driver package %2...
			%GCC% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -DLUA_JIT_51 -c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
			
			echo Linking luaw driver...
			%GCC% %attrib% %dirs% -o luaw.exe luadriver.o darr.o
		
			echo Linking default luaw driver package %2...
			%GCC% %attrib% %dirs% -shared -o lc%2.dll ldata.o jitsupport.o darr.o %dlldir%\lua51.dll
		) ELSE (
			echo Compiling luaw driver...
			%GCC% %attrib% %dirs% -D__USE_MINGW_ANSI_STDIO=1 -DDEFAULT_LUA=\"lc%2.dll\" -c %srcdir%\darr.c %srcdir%\luadriver.c
			
			echo Compiling default luaw driver package %2...
			%GCC% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
			
			echo Linking luaw driver...
			%GCC% %attrib% %dirs% -o luaw.exe luadriver.o darr.o
		
			echo Linking default luaw driver package %2...
			%GCC% %attrib% %dirs% -shared -o lc%2.dll ldata.o jitsupport.o darr.o %dlldir%\%2.dll
		)
		
		
		REM Strip luaw driver if not debug
		echo Stripping...
		IF %debug% EQU 0 (
			strip --strip-all luaw.exe
		)
		
		REM Migrate binaries
		echo Migrating binaries...
		move /Y *.dll		%root%
		move /Y *.o			%objdir%
		move /Y *.a			%libdir%
		move /Y *.exe		%root%
		copy /Y %resdir%\*	%root%\res
		copy /Y %dlldir%\*	%root%
		copy /Y %rootdir%\*	%root%
		
		echo Finished.
		exit /b 0
	)
	
	
	REM --------------------------------------------------------------------
	
	
	IF [%1] == [package] (
		IF [%2] == [luajit] (
			echo Building luajit...
			
			pushd luajit-2.0\src
				IF NOT EXIST "lua51.dll" (
					%MAKE% -j%NUMBER_OF_PROCESSORS%
				) ELSE (
					IF [%force_build%] == [1] (
						%MAKE% -j%NUMBER_OF_PROCESSORS%
					)
				)
				echo Installing...
				xcopy /Y lua.h		..\..\include
				xcopy /Y luaconf.h	..\..\include
				xcopy /Y lualib.h	..\..\include
				xcopy /Y lauxlib.h	..\..\include
				xcopy /Y luajit.h	..\..\include
				xcopy /Y lua51.dll	..\..\dll
			popd
			
			echo Finished building and linking luajit.
		) ELSE (
			echo Building %2...
			
			pushd lua-all\%2
				IF NOT EXIST "*.dll" (
					echo Compiling...
					%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra %lua_cflags% -DLUA_BUILD_AS_DLL -c *.c
					
					del lua.o
					del luac.o
					
					echo Linking...
					%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra -shared -o %2.dll *.o
					
					echo Archiving...
					%AR% rcu lib%2.a *.o
				) ELSE (
					IF [%force_build%] == [1] (
						echo Compiling...
						%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra %lua_cflags% -DLUA_BUILD_AS_DLL -c *.c
						
						del lua.o
						del luac.o
						
						echo Linking...
						%GCC% -std=%GCC_VER% -g0 -O2 -Wall -Wextra -shared -o %2.dll *.o
						
						echo Archiving...
						%AR% rcu lib%2.a *.o
					)
				)
				
				echo Installing...
				xcopy /Y lua.h			..\..\include
				xcopy /Y luaconf.h		..\..\include
				xcopy /Y lualib.h		..\..\include
				xcopy /Y lauxlib.h		..\..\include
				xcopy /Y %2.dll			..\..\dll
				xcopy /Y lib%2.a		..\..\lib
			popd
			
			echo Finished building and linking %2.
		)
		
		echo Creating local luaw package as %2...
		
		if [%2] == [luajit] (
			echo Compiling luaw package %2...
			%GCC% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -DLUA_JIT_51 -c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
			
			echo Linking luaw package %2...
			%GCC% %attrib% %dirs% -shared -o lc%2.dll ldata.o jitsupport.o darr.o %dlldir%\lua51.dll
		) ELSE (
			echo Compiling luaw package %2...
			%GCC% %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -DLC_LD_DLL -c %srcdir%\ldata.c %srcdir%\jitsupport.c %srcdir%\darr.c
			
			echo Linking luaw package %2...
			%GCC% %attrib% %dirs% -shared -o lc%2.dll ldata.o jitsupport.o darr.o %dlldir%\%2.dll
		)
		
		echo Finished building and linking %2.
		
		REM Migrate binaries
		echo Migrating binaries...
		move /Y *.dll		%root%
		move /Y *.o			%objdir%
		move /Y *.a			%libdir%
		copy /Y %resdir%\*	%root%\res
		copy /Y %dlldir%\*	%root%
		copy /Y %rootdir%\*	%root%
		
		echo Finished.
		exit /b 0
	)
	
	
endlocal


REM Simplex help message
:help
	echo Usage:
	echo.
	echo		build.bat build lua-x.x.x              Builds the driver with a default package.
	echo		build.bat package lua-x.x.x            Creates packages for the driver.
	echo		build.bat clean                        Cleans the environment of built files.
	echo		build.bat install [directory]          Installs to a pre-created directory.
	echo		build.bat -? /? --help                 Shows this help message
	echo.
	echo Notes:
	echo		Uses `debug` for debug binaries
	echo		Uses `debug_coverage` for coverage enabling
	echo		Uses `force_build` for forcing builds of packages
	echo		Uses `GCC` for specifying GCC executable
	echo		Uses `AR` for specifying AR executable
	echo		Uses `MAKE` for specifying MAKE executable
	echo		Uses `GCC_VER` for specifying lua gcc version for building lua dlls
	echo.
	echo Configure above notes with set:
	echo		debug, debug_coverage, force_build, GCC, AR, MAKE, GCC_VER
	echo.
	echo 	Specify luajit if you want to use luajit.
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	pause
	exit /b 1
