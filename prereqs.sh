#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2017-2019 Cody Tilkins
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# - Basic Variables --------------------------------------------------


if [ -z "$ZIP" ]; then ZIP="tar xzf";	fi
if [ -z "$GIT" ]; then GIT="git";	fi
if [ -z "$DLM" ]; then DLM="curl";	fi


# - Basic Functions --------------------------------------------------


function help_message() {
	echo "Usage:"
	echo "\n"
	echo "		prereqs.bat                              Downloads and extracts the lua files"
	echo "		prereqs.bat clean                        Cleans the environment of downloaded files"
	echo "		prereqs.bat -? /? --help                 Shows this help message"
	echo "\n"
	echo "Notes:"
	echo "	Uses `7zip` found in Program Files    ( https://www.7-zip.org/download.html )"
	echo "	Uses `bitsadmin` for downloading      ( core to most windows installations  )"
	echo "	Uses `git` found in PATH              ( https://gitforwindows.org/          )"
	echo "\n"
	echo "Configure above notes with set:"
	echo "		ZIP, GIT, and DLM"
	echo "\n"
	echo "		DLM should be set to bitsadmin or wget or curl. Defaults to bitsadmin."
	echo "		ZIP should be set to an unzipper that takes the .tar or .tar.gz. Defaults to 7zip."
	echo "		GIT should be set to the git program. Defaults to git in path."
	echo "\n"
}

function failure() {
	echo "An error has occured!"
	exit 1
}


# - Basic Switches ---------------------------------------------------


if [ "$1" = "/?" ]; then
	help_message
	exit 0
fi

if [ "$1" = "-?" ]; then
	help_message
	exit 0
fi

if [ "$1" = "--help" ]; then
	help_message
	exit 0
fi


# - Basic Cleaner ----------------------------------------------------


if [ "$1" = "clean" ]; then
	echo "Deleting luajit..."
	rm -f -r -d luajit-2.0
	
	echo "Deleting lua-all..."
	rm lua-all.tar.gz
	rm -f -r -d lua-all
	
	echo "Done."
	exit 0
fi


# - luajit Download --------------------------------------------------


echo "Checking for cached luajit folder ..."
if [ ! -d "luajit-2.0" ]; then
	echo "Not found. Downloading..."
	$GIT clone http://luajit.org/git/luajit-2.0.git
fi

if [ ! -d "luajit-2.0" ]; then
	echo "Failure to git download luajit."
	failure
fi

echo "Cached."


# - lua-all Download -------------------------------------------------


# lua-all download
echo "Checking for cached lua-all.tar.gz..."
if [ ! -f "lua-all.tar.gz" ]; then
	echo "Not found. Downloading..."
	if [ "$DLM" = "curl" ]; then
		curl "https://www.lua.org/ftp/lua-all.tar.gz" > lua-all.tar.gz
	fi
	if [ "$DLM" = "wget" ]; then
		echo "Not implemented!"
		failure
	fi
	if [ ! -f "lua-all.tar.gz" ]; then
		echo "lua-all.tar.gz not downloaded."
		failure
	fi
fi

echo "Cached."


# lua-all extract
echo "Checking for cached lua-all folder..."
if [ ! -d "lua-all" ]; then
	echo "Not found. Unpacking lua-all.tar.gz"
	
	$ZIP lua-all.tar.gz
	
	if [ ! -d "lua-all" ]; then
		echo "Failure to unpack lua-all."
		failure
	fi
fi

echo "Cached."


# - Exit Gracefully --------------------------------------------------


echo "Prerequisits downloaded and extracted!"

