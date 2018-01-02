
@echo off

echo ^>^>^> Cleaning bin
echo ^> bin\Debug
rmdir /S /Q bin\Debug
rmdir /S /Q bin\debug

echo ^> bin\Release
rmdir /S /Q bin\Release
rmdir /S /Q bin\release


echo ^>^>^> Cleaning obj
echo ^> *.o
del /Q *.o
del /Q obj\*.o
del /Q src\*.o
echo ^> *.a
del /Q *.a
del /Q obj\*.a
del /Q src\*.a
echo ^> *.dll
del /Q *.dll
del /Q obj\*.dll
del /Q src\*.dll

