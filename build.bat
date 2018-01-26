@echo off


setlocal
	
	set debug=1
	set luaverdef=-DLUA_JIT_51
	set luaver=lua51
	set luainc=.
	REM luainc is for external include directory only
	REM if its in /include, keep luainc set to .
	
	if %debug% EQU 0 (
		set attrib=-std=gnu99 -s -Wall -O2
		set root=bin\Release
	) else (
		set attrib=-std=gnu99 -Wall -g -O0
		set root=bin\Debug
	)
	
	set objdir=obj
	set libdir=lib
	set resdir=res
	set rootdir=root
	set dlldir=dll
	set srcdir=src
	set incdir=include
	
	set dirs=-L%srcdir% -L%libdir% -L%dlldir% -I%srcdir% -I%incdir% -I%luainc%

	
	if EXIST %root% ( rmdir /S /Q %root% )
	mkdir %root%
	mkdir %root%\res
	
	
	rem Compile everything w/ additions
	gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -c %srcdir%\consolew.c %srcdir%\darr.c
	gcc %attrib% %dirs% %luaverdef% -D__USE_MINGW_ANSI_STDIO=1 -c %srcdir%\additions.c
	
	rem Create luaadd.dll
	gcc %attrib% %dirs% -shared -o luaadd.dll additions.o %dlldir%\%luaver%.dll
	
	rem Link luaw.exe
	gcc %attrib% %dirs% -o luaw.exe consolew.o darr.o %dlldir%\%luaver%.dll
	
	
	move /Y *.dll %root% 1>nul 2>nul
	move /Y *.o %objdir% 1>nul 2>nul
	move /Y *.a %objdir% 1>nul 2>nul
	move /Y *.exe %root% 1>nul 2>nul
	copy /Y %resdir%\* %root%\res 1>nul 2>nul
	copy /Y %dlldir%\* %root% 1>nul 2>nul
	copy /Y %rootdir%\* %root% 1>nul 2>nul
	
	if %debug% EQU 0 strip --strip-all %root%\luaw.exe
	
	
	echo Done.
	
endlocal

exit /b

