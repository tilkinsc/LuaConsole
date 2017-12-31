@echo off

setlocal

set root=..\bin\debug
set objdir=..\obj
set resdir=..\res

cd src

rem Compile everything release w/ additions
gcc -std=gnu99 -Wall -O2 -g0 -DLUACON_ADDITIONS -D__USE_MINGW_ANSI_STDIO=1 -c console.c consolew.c additions.c darr.c

rem Link luaw.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua_add.exe console.o additions.o darr.o -llua

rem Link lua.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw_add.exe consolew.o additions.o darr.o -llua

rem Compile everything release w/o additions
gcc -std=gnu99 -Wall -O2 -g0 -D__USE_MINGW_ANSI_STDIO=1 -c console.c consolew.c darr.c

rem Link luaw.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o lua.exe console.o darr.o -llua

rem Link lua.exe
gcc -std=gnu99 -s -Wall -O2 -g0 -o luaw.exe consolew.o darr.o -llua
 
if EXIST %root% ( rmdir /S /Q %root% )
mkdir %root%
mkdir %root%\res

move /Y *.exe %root% >nul
move /Y *.o %objdir% >nul
copy /Y %resdir%\* %root%\res >nul

cd %root%

strip --strip-all lua_add.exe
strip --strip-all luaw_add.exe
strip --strip-all lua.exe
strip --strip-all luaw.exe

endlocal

exit /b

