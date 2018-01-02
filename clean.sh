#!/usr/bin/env bash

echo '>>> Cleaning bin'
echo '> bin\Debug'
rm --one-file-system -f -r -d bin\Debug
rm --one-file-system -f -r -d bin\debug

echo '> bin\Release'
rm --one-file-system -f -r -d bin\Release
rm --one-file-system -f -r -d bin\release


echo '>>> Cleaning obj'
echo '> *.o'
rm --one-file-system *.o
rm --one-file-system obj\*.o
rm --one-file-system src\*.o
echo '> *.a'
rm --one-file-system *.a
rm --one-file-system obj\*.a
rm --one-file-system src\*.a
echo '> *.dll'
rm --one-file-system *.dll
rm --one-file-system obj\*.dll
rm --one-file-system src\*.dll

