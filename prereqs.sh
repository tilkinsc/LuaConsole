#!/bin/bash

# MIT License
# 
# Copyright (c) 2017-2021 Cody Tilkins
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


[[ -z "${ZIP}" ]] &&	ZIP="tar"
[[ -z "${GIT}" ]] &&	GIT="git"
[[ -z "${DLM}" ]] &&	DLM="curl"


# - Basic Functions --------------------------------------------------


error() {
	printf "\n\n$0 : ${2} : Error: ${1}\n" 1>&2
	exit 1
}

# TODO: translate, 'cat prereqs.espanol.linux.help'
help_message() {
	printf """
Usage:
    
    prereqs download         Downloads and extracts the dependencies
    prereqs clean            Cleans the environment of downloaded files
    prereqs reset            Removes and re-extracts the dependencies
    prereqs -? /? --help     Shows this help message
    
Listens to these variables:
    ZIP, GIT, and DLM
    
    ZIP - tar, 7zip             Default: tar
    GIT - git binary            Default: git
    DLM - wget, curl            Default: curl
    
Notes:
    Uses '7zip'	                ( apt-get install p7zip-full )
    Uses 'git'                  ( apt-get install git        )
    
"""
	exit 0
}


# - Basic Switches ---------------------------------------------------


[[ -z "${1}" || "${1}" == "/?" || "${1}" == "-?" || "${1}" == "--help" ]] && help_message


# - Basic Dependencies Checking --------------------------------------


if [[ "${ZIP}" == "7zip" ]]; then
	which "7z" || error "\$ZIP - 7zip requested but not found in path" $LINENO
fi
if [[ "${ZIP}" == "tar" ]]; then
	which "tar" || error "\$ZIP - tar requested but not found in path" $LINENO
fi

if [[ "${GIT}" == "git" ]]; then
	which "${GIT}" || error "\$GIT - git requested but not found by '${GIT}'" $LINENO
fi

if [[ "${DLM}" == "curl" ]]; then
	which "curl" || error "\$DLM - curl requested but not found in path" $LINENO
fi
if [[ "${DLM}" == "wget" ]]; then
	which "wget" || error "\$DLM - wget requested but not found in path" $LINENO
fi


# - Basic Innerworking Variables -------------------------------------


CWD="$(pwd)"


# - Basic Cleaner ----------------------------------------------------


if [[ "${1}" == "clean" ]]; then
	printf "Deleting luajit (${CWD}/luajit-2.0)...\n"
	rm -f -r -d -I "${CWD}/luajit-2.0"
	
	printf "Deleting lua-all (${CWD}/lua-all)...\n"
	rm -i "${CWD}/lua-all.tar.gz"
	rm -f -r -d -I "${CWD}/lua-all"
	
	printf "Done.\n"
	exit 0
fi


# - Basic Reseter ----------------------------------------------------


if [[ "${1}" == "reset" ]]; then
	printf "Cleaning (${CWD}/luajit-2.0)...\n"
	rm -f -r ${CWD}/luajit-2.0/*.o
	rm -f -r ${CWD}/luajit-2.0/*.so
	rm -f -r ${CWD}/luajit-2.0/*.so.*
	rm -f -r ${CWD}/luajit-2.0/*.dll
	rm -f -r ${CWD}/luajit-2.0/*.lib
	rm -f -r ${CWD}/luajit-2.0/*.exp
	
	printf "Cleaning (${CWD}/lua-all)...\n"
	rm -f -r -d -I "${CWD}/lua-all"
	
	printf "Extracting (${CWD}/lua-all.tar.gz)...\n"
	[[ "${ZIP}" == "tar" ]] && tar xzf "${CWD}/lua-all.tar.gz"
	[[ "${ZIP}" == "7zip" ]] && 7z x "${CWD}/lua-all.tar.gz"
	[[ -d "${CWD}/lua-all" ]] || error "failed to unpack '${CWD}/lua-all' using ${ZIP}" $LINENO
	
	printf "Done.\n"
	exit 0
fi


# - Lua Download -----------------------------------------------------


if [[ "${1}" == "download" ]]; then
	printf "Checking for cached (${CWD}/luajit-2.0) folder...\n"
	if [[ ! -d "${CWD}/luajit-2.0" ]]; then
		printf "Not found. Downloading...\n"
		$GIT clone "http://luajit.org/git/luajit-2.0.git" || error "failed to clone luajit-2.0 using ${GIT}" $LINENO
	fi
	printf "Cached.\n"

	printf "Checking for cached (${CWD}/lua-all.tar.gz) file...\n"
	if [[ ! -f "${CWD}/lua-all.tar.gz" ]]; then
		printf "Not found. Downloading...\n"
		[[ "${DLM}" == "curl" ]] && curl "https://www.lua.org/ftp/lua-all.tar.gz" > "${CWD}/lua-all.tar.gz"
		[[ "${DLM}" == "wget" ]] && wget "https://www.lua.org/ftp/lua-all.tar.gz"
		[[ -f "${CWD}/lua-all.tar.gz" ]] || error "failed to download lua-all using ${ZIP}" $LINENO
	fi
	printf "Cached.\n"

	printf "Checking for cached (${CWD}/lua-all) folder...\n"
	if [[ ! -d "${CWD}/lua-all" ]]; then
		printf "Not found. Unpacking...\n"
		[[ "${ZIP}" == "tar" ]] && tar xzf "${CWD}/lua-all.tar.gz"
		[[ "${ZIP}" == "7zip" ]] && 7z x "${CWD}/lua-all.tar.gz"
		[[ -d "${CWD}/lua-all" ]] || error "failed to unpack '${CWD}/lua-all' using ${ZIP}" $LINENO
	fi
	printf "Cached.\n"

	printf "Dependencies downloaded successfully.\n"
	exit 0
fi

error "${*} are not a valid arguments" $LINENO

