@echo off

setlocal
	
	"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
	
	prereqs.bat download
	build.msvs.bat driver luajit
	build.msvs.bat package lua-5.4.2
	build.msvs.bat package lua-5.3.6
	build.msvs.bat package lua-5.2.4
	build.msvs.bat package lua-5.1.5
	
endlocal

