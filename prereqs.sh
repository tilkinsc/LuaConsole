#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2017-2018 Cody Tilkins
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

help_message=""

if [[ -z $1 ]]; then
	echo No arguments specified. \n
	echo $help_message
	exit 1
fi

if [[ $1 -eq "/?" ]]; then
	echo $help_message
	exit 0
fi

if [[ $1 -eq "-?" ]]; then
	echo $help_message
	exit 0
fi

if [[ $1 -eq "--help" ]]; then
	echo $help_message
	exit 0
fi

if [[ -z $2 ]]; then
	echo Not enough arguments supplied. Missing 2nd argument. \n
	echo $help_message
fi

arg1=$2
luaver=${arg1:0,3}-${arg1:3,1}.${arg1:4,1}.${arg1:5,1}

if [[ -z GIT ]]; then
	GIT=git
fi
if [[ -z luaw_cflags ]]; then
	luaw_cflags=-DLUA_COMPAT_ALL -DLUA_COMPAT_5_2
fi
if [[ -z GCC ]]; then
	GCC=gcc
fi
if [[ -z AR ]]; then
	AR=ar
fi

if [[ $1 -eq "build" ]]; then
	
	if [[ $2 -eq "all" ]]; then
		echo Not yet supported! \n
		echo $help_message
		exit 1
	fi
	
	# IF NOT [$arg1:~0,3] == lua
	#
	# fi
	
	if [[ $2 -eq "luajit" ]]; then
	
	fi
	
fi

if [[ $1 -eq "clean" ]]; then
	if [[ $2 -eq "all" ]]; then
	
	fi
	
	
fi

if [[ $1 -eq "switch" ]]; then
	if [[ $2 -eq "luajit" ]]; then
	
	fi
	
	
fi
	











