@echo off

setlocal

	set root=..\bin\debug
	set objdir=..\obj
	set resdir=..\res


	cd src
		
		if EXIST %root% ( rmdir /S /Q %root% )
		mkdir %root%
		mkdir %root%\res
		
		
		rem Compile everything release w/ additions
		gcc -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -DLUACON_ADDITIONS -D__USE_MINGW_ANSI_STDIO=1 -c console.c consolew.c additions.c darr.c
		
		rem Create luaadd.dll luaadd.dll.a
		gcc -s -shared -Wl,--out-implib,libluaadd.dll.a -O2 -g0 -Wall -L. -Llib -Ldll -Iinclude -o luaadd.dll additions.o -llua53.dll
		
		rem Link luaw.exe
		gcc -s -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -o lua.exe console.o darr.o -llua53.dll -lluaadd.dll
		
		rem Link lua.exe
		gcc -s -Wall -O2 -g0 -L. -Llib -Ldll -Iinclude -o luaw.exe consolew.o darr.o -llua53.dll -lluaadd.dll
		
		
		move /Y *.dll %root% >nul
		move /Y *.exe %root% >nul
		move /Y *.o %objdir% >nul
		move /Y *.a %objdir% >nul
		copy /Y %resdir%\* %root%\res >nul
		
		
		strip --strip-all %root%\lua.exe
		strip --strip-all %root%\luaw.exe
		
	cd ..
	
endlocal

exit /b

