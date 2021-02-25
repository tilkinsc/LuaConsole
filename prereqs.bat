
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
	
	REM - Basic Variables --------------------------------------------
	
	
	IF NOT DEFINED ZIP	set "ZIP=7zip"
	IF NOT DEFINED GIT	set "GIT=git"
	IF NOT DEFINED DLM	set "DLM=bitsadmin"
	
	
	REM - Basic Switches ---------------------------------------------
	
	
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
	
	
	REM - Basic Dependencies Checking --------------------------------
	
	
	setlocal EnableDelayedExpansion
		IF [7zip] == [%ZIP%] (
			where 7z.exe
			IF [!errorlevel!] == [1] (
				echo %%ZIP%% - 7zip requested but not found in path
				goto failure
			)
		)
		
		IF [git] == [%GIT%] (
			where git.exe
			IF [!errorlevel!] == [1] (
				echo %%GIT%% - git requested but not found in path
				goto failure
			)
		)
		
		IF [bitsadmin] == [%DLM%] (
			where bitsadmin.exe
			IF [!errorlevel!] == [1] (
				echo %%DLM%% - bitsadmin requested but not found in path
				goto failure
			)
		)
		
		IF [curl] == [%DLM%] (
			where curl.exe
			IF [!errorlevel!] == [1] (
				echo %%DLM%% - curl requested but not found in path
				goto failure
			)
		)
		
		IF [wget] == [%DLM%] (
			where wget.exe
			IF [!errorlevel!] == [1] (
				echo %%DLM%% - wget requested but not found in path
				goto failure
			)
		)
	endlocal
	
	
	REM - Basic Innerworking Variables -------------------------------
	
	
	set "CWD=%CD%"
	
	
	REM - Basic Cleaner ----------------------------------------------
	
	
	IF [clean] == [%1] (
		echo Deleting luajit %CWD%\luajit-2.0 ...
		rmdir /S %CWD%\luajit-2.0
		
		echo Deleting lua-all %CWD%\lua-all ...
		del %CWD%\lua-all.tar
		del %CWD%\lua-all.tar.gz
		rmdir /S %CWD%\lua-all
		
		echo Done.
		exit /b 0
	)
	
	
	REM - Basic Reseter ----------------------------------------------
	
	
	IF [reset] == [%1] (
		echo Cleaning %CWD%\luajit ...
		del /F /S %CWD%\luajit-2.0\*.o
		del /F /S %CWD%\luajit-2.0\*.so
		del /F /S %CWD%\luajit-2.0\*.so.*
		del /F /S %CWD%\luajit-2.0\*.dll
		del /F /S %CWD%\luajit-2.0\*.lib
		del /F /S %CWD%\luajit-2.0\*.exp
		
		echo Cleaning  %CWD%\lua-all ...
		rmdir /S /Q %CWD%\lua-all
		del /F /S %CWD%\lua-all.tar
		
		IF [7zip] == [%ZIP%] 7z x %CWD%\lua-all.tar.gz
		IF EXIST "%CWD%\lua-all.tar" 7z x %CWD%\lua-all.tar
		IF NOT EXIST "%CWD%/lua-all" (
			echo failed to unpack '%CWD/lua-all'
			goto error
		)
		
		echo Done.
		exit /b 0
	)
	
	
	REM - Lua Download -----------------------------------------------
	
	
	IF [download] == [%1] (
		echo Checking for cached %CWD%\luajit-2.0 folder ...
		IF NOT EXIST "%CWD%\luajit-2.0" (
			echo Not found. Downloading...
			%GIT% clone "http://luajit.org/git/luajit-2.0.git"
			IF NOT EXIST "%CWD%\luajit-2.0" (
				echo "failed to clone luajit-2.0"
				goto error
			)
		)
		echo Cached.
		
		echo Checking for cached %CWD%\lua-all.tar.gz folder ...
		IF NOT EXIST "%CWD%\lua-all.tar.gz" (
			echo Not found. Downloading...
			IF [bitsadmin] == [%DLM%] bitsadmin.exe /TRANSFER "lua-all.tar.gz" "https://www.lua.org/ftp/lua-all.tar.gz" %CWD%\lua-all.tar.gz
			IF [wget] == [%DLM%] wget.exe "https://www.lua.org/ftp/lua-all.tar.gz"
			IF [curl] == [%DLM%] curl "https://www.lua.org/ftp/lua-all.tar.gz" > %CWD%\lua-all.tar.gz
			IF NOT EXIST "%CWD%\lua-all.tar.gz" (
				echo failed to download lua-all
				goto error
			)
		)
		echo Cached.
		
		echo Checking for cached %CWD%\lua-all folder...
		IF NOT EXIST "lua-all" (
			echo Not found. Unpacking...
			IF [7zip] == [%ZIP%] (
				7z x %CWD%\lua-all.tar.gz
				IF EXIST "%CWD%\lua-all.tar" 7z x %CWD%\lua-all.tar
			)
			IF NOT EXIST "%CWD%\lua-all" (
				echo failed to unpack lua-all
				goto failure
			)
		)
		echo Cached.
	)
	
	echo Dependencies downloaded successfully.
	exit /b 0
	
endlocal


REM Simplex help message
REM TODO: translate, 'type prereqs.espanol.win32.help'
:help
	echo Usage:
	echo.
	echo     prereqs download         Downloads and extracts the dependencies
	echo     prereqs clean            Cleans the environment of downloaded files
	echo     prereqs reset            Removes and re-extracts the dependencies
	echo     prereqs -? /? --help     Shows this help message
	echo.
	echo Notes:
	echo     Uses '7zip'                  ( https://www.7-zip.org/download.html )
	echo     Uses 'bitsadmin'             ( core to most windows installations  )
	echo     Uses 'git'                   ( https://gitforwindows.org/          )
	echo.
	echo Listens to these variables:
	echo     ZIP, GIT, and DLM
	echo.
	echo     ZIP should be set to 7zip.                      Defaults to 7zip.
	echo     GIT should be set to the git binary.            Defaults to git.
	echo     DLM should be set to bitsadmin, wget or curl.   Defaults to bitsadmin.
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	exit /b 1

