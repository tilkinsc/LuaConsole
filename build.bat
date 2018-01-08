@echo off


setlocal

	set root=..\bin\Debug
	set objdir=..\obj
	set resdir=..\res
	set dlldir=..\dll
	set lua_ver=lua51


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
		
		
		move /Y *.dll %root% 1>nul 2>nul
		move /Y *.exe %root% 1>nul 2>nul
		move /Y *.o %objdir% 1>nul 2>nul
		move /Y *.a %objdir% 1>nul 2>nul
		copy /Y %resdir%\* %root%\res 1>nul 2>nul
		copy /Y %dlldir%\* %root% 1>nul 2>nul
		
		strip --strip-all %root%\luaw.exe
		
		echo Done.
	cd ..
	
endlocal

exit /b

