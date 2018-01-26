
-- define v this or use -Dplat=Windows -- Linux -- MacOSX
-- plat = os.types.Windows -- os.types.Linux -- os.types.MacOSX

if(plat == nil)then
	error("Please define plat as Windows, Linux, or MacOSX")
end

require("luaadd")
require("build_func")


local lua_ver = choose_opt("lua51", "luajit-5.1", "luajit-5.1")
local lua_define = " -DLUA_JIT_51"
local lua_includes = choose_opt("", "/usr/local/include/luajit-2.0", "/usr/local/include/luajit-2.0")


--[[
	gcc setup
	
--]]

local gcc = {
	gcc_name = "gcc";
	debug = true;
	warnings = " -Wall";
	windows = false;
	extra_warnings = "";
	include_dir = " -I. -Iinclude";
	library_dir = " -L. -Llib -Lobj -Ldll";
	ccextras = " -s" .. lua_define;
	ldextras = choose_opt(" -s", " -s -fPIC -Wl,-E", " -s -Wl,-E");
	defines = choose_opt(" -D__USE_MINGW_ANSI_STDIO=1", "", "");
}
gcc.g = gcc.debug and 3 or 0
gcc.O = gcc.debug and 0 or 2

local install_path = plat == os.types.Windows and (gcc.debug and ("bin\\Debug") or ("bin\\Release")) or ((plat == os.types.Linux or plat == os.types.MacOSX) and (gcc.debug and ("bin/Debug") or ("bin/Release")))


-- this is only a print
local targ_dir = (gcc.debug and "DEBUG" or "RELEASE")


--[[
	cache setup
	
--]]

local targ1_exe = {enc_exe("luaw")}
local targ1_compile_units = {"consolew.c", "darr.c"}

local targ2_dll = {enc_dll("luaadd")}
local targ2_compile_units = {"additions.c"}

local exe_test = true

if(no_cache == nil) then
	if(cache == nil)then
		targ1_compile_units = check_cache(targ1_compile_units, "src/", "obj/", "o")
		targ2_compile_units = check_cache(targ2_compile_units, "src/", "obj/", "o")

		exe_test = 
			   check_bin_cache(targ1_exe, "src/", install_path .. "\\", targ1_compile_units)
			or check_bin_cache(targ1_exe, "src/", install_path .. "\\", targ2_compile_units)
			or check_bin_cache(targ2_dll, "src/", install_path .. "\\", targ1_compile_units)
			or check_bin_cache(targ2_dll, "src/", install_path .. "\\", targ2_compile_units)
	end

	if(#targ1_compile_units == 0 and #targ2_compile_units == 0 and not exe_test and force == nil)then
		print("Done. Up to date.")
		return
	end
end


--[[
	objects setup

--]]

local std_libs = enc_dll(" -l" .. lua_ver) .. choose_opt("", " -lm -ldl", " -lm -ldl")


local targ1_luaw_exe = enc_exe("luaw")
local targ1_luaw_exe_o = {"consolew.o", "darr.o"}
local targ1_lua_exe_libs = std_libs


local targ2_luaadd_dll_a = nil
local targ2_luaadd_dll = enc_dll("luaadd")
local targ2_luaadd_o = {"additions.o"}
local targ2_luaadd_libs = std_libs



--[[
	compiler/linker strings
	
--]]

-- compile string
local compile_str1 = gcc_c(
		gcc.g, gcc.O, gcc.warnings, gcc.extra_warnings,
		gcc.defines,
		gcc.ccextras,
		gcc.include_dir,
		gcc.library_dir,
		targ1_compile_units)
		
local compile_str2 = gcc_c(
		gcc.g, gcc.O, gcc.warnings, gcc.extra_warnings,
		gcc.defines,
		gcc.ccextras,
		gcc.include_dir,
		gcc.library_dir,
		targ2_compile_units)
		
-- generate dll/so string
local linker_str_dll1 = choose_gcc_dll()(
		targ2_luaadd_dll_a,
		gcc.g, gcc.O, gcc.warnings, gcc.extra_warnings,
		gcc.defines,
		gcc.ldextras,
		gcc.include_dir,
		gcc.library_dir,
		targ2_luaadd_dll,
		targ2_luaadd_o,
		targ2_luaadd_libs)


-- luaw linker string
local linker_str_exe1 = gcc_l(
		gcc.windows,
		gcc.g, gcc.O, gcc.warnings, gcc.extra_warnings,
		gcc.ldextras,
		gcc.include_dir,
		gcc.library_dir,
		targ1_luaw_exe,
		targ1_luaw_exe_o,
		targ1_lua_exe_libs)



--[[
	command procedurals
	
--]]

-- compile
if(#targ1_compile_units > 0 or exe_test or force)then
	compiler_exec(targ_dir, compile_str1)
	obj_transfer()
end
if(#targ2_compile_units > 0 or exe_test or force)then
	compiler_exec(targ_dir, compile_str2)
	obj_transfer()
end


if(#targ1_compile_units + #targ2_compile_units > 0 or exe_test or force)then
	-- link dll
	linker_exec(enc_dll(" luaadd"), linker_str_dll1)
	obj_transfer()

	-- link exe
	linker_exec("luaw", linker_str_exe1)
	
	-- strip redundancy
	if(not gcc.debug)then
		strip_targ(enc_exe("luaw"))
	end
	
	-- setup
	migrate_binaries(install_path, {enc_exe("luaw"), enc_dll("luaadd")})
end
print("Done. Up to date.")


