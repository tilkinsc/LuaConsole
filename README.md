# LuaConsole

A simple, powerful lua console with the intent of replacing CMD and Terminal

Lua Console | Version: 5/6/2017

Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio

LuaConsole Copyright MIT (C) 2017 Hydroque

        - Line by Line interpretation
        - Files executed by passing
        - Working directory support
        - Built in stack-dump

Supports Lua5.3, Lua5.2, Lua5.1

5.2.x and 5.1.x assume that you have enough memory for initial functions.


Usage: lua.exe [FILE_PATH] [-v] [-e] [-s START_PATH] [-p] [-a] [-c] [-?]


-v      Prints the Lua version in use

-e      Prevents lua core libraries from loading

-s      Issues a new root path

-p      Has console post exist after script in line by line mode

-a      Removes the additions

-c      No copyright on init

-?      Displays this help message
