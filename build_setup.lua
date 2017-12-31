--[[
	gcc setup
	
--]]

gcc = {
	gcc_name = "gcc";
	debug = true;
	warnings = " -Wall";
	windows = false;
	extra_warnings = "";
	libraries = " -llua";
	include_dir = " -I. -Iinclude";
	library_dir = " -L. -Llib -Ldll";
	extras = "";
	defines = " -DLUACON_ADDITIONS -D__USE_MINGW_ANSI_STDIO=1";
}
gcc.g = gcc.debug and 3 or 0
gcc.O = gcc.debug and 0 or 2

install_path = build_type == os.types.Windows and (gcc.debug and ("bin\\Debug") or ("bin\\Release")) or (build_type == os.types.Linux and (gcc.debug and ("bin/Debug") or ("bin/Release")))
