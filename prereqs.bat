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
	
	
	
	REM Pre-emptive variables. Can't be set in IF statements easily.
	set arg1=%2
	set luaver=%arg1:~0,3%-%arg1:~3,1%.%arg1:~4,1%.%arg1:~5,1%
	
	IF NOT DEFINED ZIP7	set "ZIP7=C:\Progra~1\7-Zip\7z.exe"
	IF NOT DEFINED GIT set "GIT=git"
	IF NOT DEFINED luaw_cflags	set luaw_cflags=-DLUA_COMPAT_ALL -DLUA_COMPAT_5_2
	IF NOT DEFINED GCC set "GCC=gcc"
	IF NOT DEFINED AR set "AR=ar"
	IF NOT DEFINED INST set "INST=bitsadmin.exe"
	
	
	
	REM Build target
	IF [%1] == [build] (
		REM All targets
		IF [%2] == [all] (
			echo Not yet supported!
			echo.
			goto help
		)
		
		REM Ensure argument correctness
		IF NOT [%arg1:~0,3%] == [lua] (
			echo Invalid lua version argument specified.
			echo.
			goto help
		)
		
		REM Download, make, and install luajit only
		IF [%2] == [luajit] (
			IF NOT EXIST "%GIT%" goto failgit
			%GIT% clone http://luajit.org/git/luajit-2.0.git
			
			pushd luajit-2.0\src
				make -j%NUMBER_OF_PROCESSORS%
				xcopy /Y lua.h		..\..\include
				xcopy /Y luaconf.h	..\..\include
				xcopy /Y lualib.h	..\..\include
				xcopy /Y lauxlib.h	..\..\include
				xcopy /Y luajit.h	..\..\include
				xcopy /Y lua51.dll	..\..\dll
			popd
			
			echo Done. Installed luajit-2.0 to local program directory.
			exit /b 0
		)
		
		IF NOT EXIST "%ZIP7%" goto fail7z
		
		call :download
		IF NOT EXIST "%luaver%.tar.gz" (
			echo Failed to download.
			exit /b 1
		)
		REM Ensure filesystem
		IF EXIST "%luaver%" (
			echo Cached. Refreshing files...
			del /Q /S %luaver%		1>nul 2>nul
			rmdir /Q /S %luaver%	1>nul 2>nul
		)
		call :unzip
		call :build
		
		echo Done. Installed %luaver% to the local directory.
		exit /b 0
	)
	
	
	
	IF [%1] == [clean] (
		IF [%2] == [all] (
			setlocal EnableDelayedExpansion
				FOR %%a IN (*) DO (
					set b=%%a
					set c=!b:~0,4!
					IF [!c!] == [lua-] del /p %%a
				)
			endlocal
			
			echo Done!
			exit /b 0
		)
		
		setlocal EnableDelayedExpansion
			FOR %%a IN (*) DO (
				set b=%%a
				set c=!b:~0,9!
				IF [!c!] == [%luaver%] del /p %%a
			)
		endlocal
		
		echo Done!
		exit /b 0
	)
	
	
:psdlc_redo
	IF [%1] == [switch] (
		IF [%2] == [luajit] (
			IF EXIST "luajit-2.0" (
				pushd luajit-2.0\src
					xcopy /Y lua.h		..\..\include
					xcopy /Y luaconf.h	..\..\include
					xcopy /Y lualib.h	..\..\include
					xcopy /Y lauxlib.h	..\..\include
					xcopy /Y luajit.h	..\..\include
					xcopy /Y lua51.dll	..\..\dll
				popd
				exit /b
			) ELSE (
				echo luajit not in local directory. Download? (Y/N^)
				setlocal EnableDelayedExpansion
:psdlclj_redo
					set /p dl=
					IF [!dl!]==[Y] goto psdlclj_yes
					IF [!dl!]==[y] goto psdlclj_yes
					IF [!dl!]==[N] goto psdlclj_no
					IF [!dl!]==[n] goto psdlclj_no
					goto psdlclj_redo
:psdlclj_yes
					call prereqs.bat build luajit
					IF %errorlevel% NEQ 0 (
						echo Failed to build and switch.
						exit /b 1
					)
					goto psdlclj_redo
					exit /b 0
:psdlclj_no
				endlocal
				exit /b 0
			)
			exit /b 1
		)
		IF EXIST "%luaver%" (
			echo Installing %luaver% into local directory...
			pushd %luaver%\src
				xcopy /Y lua.h			..\..\include
				xcopy /Y luaconf.h		..\..\include
				xcopy /Y lualib.h		..\..\include
				xcopy /Y lauxlib.h		..\..\include
				xcopy /Y %arg1%.dll		..\..\dll
				xcopy /Y lib%arg1%.a	..\..\lib
			popd
			exit /b 0
		) ELSE (
			echo %luaver% not in local directory. Download? (Y/N^)
			setlocal EnableDelayedExpansion
:psdlc_redo
				set /p dl=
				IF [!dl!]==[Y] goto psdlc_yes
				IF [!dl!]==[y] goto psdlc_yes
				IF [!dl!]==[N] goto psdlc_no
				IF [!dl!]==[n] goto psdlc_no
				goto psdlc_redo
:psdlc_yes
				call prereqs.bat build %arg1%
				IF %errorlevel% NEQ 0 (
					echo Failed to build and switch. Does this lua version exist?
					exit /b 1
				)
				goto psdlc_redo
				exit /b 0
:psdlc_no
			endlocal
			exit /b 0
		)
		exit /b 1
	)
	exit /b 1
	
endlocal

exit /b 1



:download
	REM Download
	IF NOT EXIST "%luaver%.tar.gz" (
		echo Downloading %luaver% with %INST%...
		
		IF [%INST%]==[bitsadmin.exe] %INST% /TRANSFER "%luaver%" https://www.lua.org/ftp/%luaver%.tar.gz %cd%\%luaver%.tar.gz
		REM TODO: wget
		REM TODO: curl
	)
	exit /b 0


:unzip
	REM Unzip
	echo Unzipping %luaver% with %ZIP7%...
	%ZIP7% x -y %luaver%.tar.gz		1>nul
	%ZIP7% x -y %luaver%.tar		1>nul
	exit /b 0


:build
	REM Building
	pushd %luaver%\src
		echo Compiling %luaver% with %GCC%...
		%GCC% -std=gnu99 -g0 -O2 -Wall -Wextra %luaw_cflags% -DLUA_BUILD_AS_DLL -c *.c
		IF %errorlevel% NEQ 0 goto failgcc
		del lua.o
		del luac.o
		echo Linking %luaver% with %GCC%...
		%GCC% -std=gnu99 -g0 -O2 -Wall -Wextra -shared -o %arg1%.dll *.o
		IF %errorlevel% NEQ 0 goto failgcc
		echo Archiving %luaver% with %AR%...
		%AR% rcu lib%arg1%.a *.o
		IF %errorlevel% NEQ 0 goto failgcc
		REM note: I also transfered libluaXYZ.a for you in case you wanna use it :)
		REM TODO: probably want to prereqs.bat switch it
	popd
	exit /b 0


:help
	REM Simplex help message
	echo Usage:
	echo.
	echo prereqs.bat build {all,luajit,lua515,lua535,...}
	echo prereqs.bat clean {all,luajit,lua515,lua535,...}
	echo prereqs.bat switch {luajit,lua515,lua535,...}
	echo.
	echo Note: Most lua versions supported, but must use 3 digit numbers.
	echo.
	echo	IMPORTANT:
	echo 	7zip required. Define ZIP7 to change path. Defaults to `C:\Progra~1\7-Zip\7z.exe`
	echo	GCC required. Define GCC to change path. Defaults to `gcc`
	echo	AR required. Define AR to change path. Defaults to `ar`
	echo	GIT required. Define GIT to change path. Defaults to `git`
	echo	Define luaw_cflags to change Lua's defines/gcc options. Defaults to `-DLUA_COMPAT_ALL -DLUA_COMPAT_5_2`
	echo	A download method is required. Define INST to change type. Defaults to `bitsadmin.exe`
	echo.
	exit /b 1



:failgit
	echo Could not find git!
	exit /b 1

:fail7z
	echo Could not find 7zip!
	exit /b 1

:failgcc
	echo GCC returned not 0!
	exit /b 1

:end
exit /b

