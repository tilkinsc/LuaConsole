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

	REM - Basic Variables --------------------------------------------------
	
	
	IF NOT EXIST ZIP	set "ZIP=C:\Progra~1\7-Zip\7z.exe x -y"
	IF NOT EXIST GIT	set "GIT=git"
	IF NOT EXIST DLM	set "DLM=bitsadmin"
	
	
	REM - Basic Switches ---------------------------------------------------
	
	IF [/?] == [%1] (
		goto help
	)
	IF [-?] == [%1] (
		goto help
	)
	IF [--help] == [%1] (
		goto help
	)
	
	
	REM - Basic Cleaner ----------------------------------------------------
	
	
	IF [clean] == [%1] (
		echo Deleting luajit...
		rmdir /S /Q luajit-2.0
		
		echo Deleting lua-all...
		del lua-all.tar
		del lua-all.tar.gz
		rmdir /S /Q lua-all
		
		echo Done.
		exit /b 0
	)
	
	
	REM - luajit Download --------------------------------------------------
	
	
	echo Checking for cached luajit folder ...
	IF NOT EXIST "luajit-2.0" (
		echo Not found. Downloading...
		%GIT% clone http://luajit.org/git/luajit-2.0.git
	)
	
	IF NOT EXIST "luajit-2.0" (
		echo Failure to git download luajit.
		goto failure
	)
	
	echo Cached.
	
	
	REM - lua-all Download -------------------------------------------------
	
	
	REM lua-all download
	echo Checking for cached lua-all.tar.gz...
	IF NOT EXIST "lua-all.tar.gz" (
		echo Not found. Downloading...
		IF [bitsadmin] == [%DLM%] (
			bitsadmin.exe /TRANSFER "lua-all.tar.gz" https://www.lua.org/ftp/lua-all.tar.gz %cd%\lua-all.tar.gz
		)
		IF [wget] == [%DLM%] (
			echo Not implemented!
			goto failure
		)
		IF [curl] == [%DLM%] (
			echo Not implemented!
			goto failure
		)
		IF NOT EXIST "lua-all.tar.gz" (
			echo lua-all.tar.gz not downloaded.
			goto failure
		)
	)
	echo Cached.
	
	REM lua-all extract
	echo Checking for cached lua-all folder...
	IF NOT EXIST "lua-all" (
		echo Not found. Unpacking lua-all.tar.gz...
		
		%ZIP% lua-all.tar.gz
		%ZIP% lua-all.tar
		
		IF NOT EXIST "lua-all" (
			echo Failed to unpack lua-all.
			goto failure
		)
	)
	echo Cached.
	
	
	REM - Exit Gracefully --------------------------------------------------
	
	
	echo Prerequisits downloaded and extracted!
	exit /b 0
	
endlocal


REM Simplex help message
:help
	echo Usage:
	echo.
	echo		prereqs.bat                              Downloads and extracts the lua files
	echo		prereqs.bat clean                        Cleans the environment of downloaded files
	echo		prereqs.bat -? /? --help                 Shows this help message
	echo.
	echo Notes:
	echo 	Uses `7zip` found in Program Files    ( https://www.7-zip.org/download.html )
	echo 	Uses `bitsadmin` for downloading      ( core to most windows installations  )
	echo 	Uses `git` found in PATH              ( https://gitforwindows.org/          )
	echo.
	echo Configure above notes with set:
	echo		ZIP, GIT, and DLM
	echo.
	echo		DLM should be set to bitsadmin or wget or curl. Defaults to bitsadmin.
	echo		ZIP should be set to an unzipper that takes the .tar or .tar.gz. Defaults to 7zip.
	echo		GIT should be set to the git program. Defaults to git in path.
	echo.
	exit /b 0


REM General failure message
:failure
	echo An error has occured!
	pause
	exit /b 1
