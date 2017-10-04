@echo off

cd src

rem Compile everything release w/ additions
gcc -std=gnu99 -Wall -O2 -g0 -DLUACON_ADDITIONS -c console.c consolew.c additions.c

rem Link luaw.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua_add.exe console.o additions.o -llua

rem Link lua.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw_add.exe consolew.o additions.o -llua

rem Compile everything release w/o additions
gcc -std=gnu99 -Wall -O2 -g0 -c console.c consolew.c

rem Link luaw.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua.exe console.o -llua

rem Link lua.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw.exe consolew.o -llua

move /Y *.exe ..\bin >nul

cd ..\bin

strip --strip-all lua_add.exe
strip --strip-all luaw_add.exe
strip --strip-all lua.exe
strip --strip-all luaw.exe

cd ..
