@echo off


setlocal

	set root=..\bin\Debug
	set objdir=..\obj
	set resdir=..\res
	set lua_ver=lua53


	cd src
		
		if EXIST %root% ( rmdir /S /Q %root% )
		mkdir %root%
		mkdir %root%\res
		
		
		rem Compile everything release w/ additions
		gcc -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -D__USE_MINGW_ANSI_STDIO=1 -c consolew.c additions.c darr.c
		
		rem Create luaadd.dll luaadd.dll.a
		gcc -s -shared -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -o luaadd.dll additions.o -l%lua_ver%.dll
		
		rem Link luaw.exe
		gcc -s -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -o luaw.exe consolew.o darr.o -l%lua_ver%.dll
		
		
		move /Y *.dll %root% >nul
		move /Y *.exe %root% >nul
		move /Y *.o %objdir% >nul
		move /Y *.a %objdir% >nul
		copy /Y %resdir%\* %root%\res >nul
		
		
		strip --strip-all %root%\luaw.exe
		
	cd ..
	
endlocal

exit /b

