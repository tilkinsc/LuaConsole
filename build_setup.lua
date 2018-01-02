--[[
	gcc setup
	
--]]

gcc = {
	gcc_name = "gcc";
	debug = true;
	warnings = " -Wall";
	windows = false;
	extra_warnings = "";
	include_dir = " -I. -Iinclude";
	library_dir = " -L. -Llib -Lobj -Ldll";
	ccextras = " -s";
	ldextras = " -s";
	defines = " -DLUACON_ADDITIONS -D__USE_MINGW_ANSI_STDIO=1";
}
gcc.g = gcc.debug and 3 or 0
gcc.O = gcc.debug and 0 or 2

install_path = plat == os.types.Windows and (gcc.debug and ("bin\\Debug") or ("bin\\Release")) or ((plat == os.types.Linux or plat == os.types.MacOSX) and (gcc.debug and ("bin/Debug") or ("bin/Release")))
