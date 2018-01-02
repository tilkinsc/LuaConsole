
-- define v this or use -Dplat=Windows -- Linux -- MacOSX
-- plat = os.types.Windows -- os.types.Linux -- os.types.MacOSX

if(plat == nil)then
	error("Please define plat as Windows Linux or MacOSX")
end


require("build_func")
require("build_setup")



local targ_dir = (gcc.debug and "DEBUG" or "RELEASE")

local targ_exe = {enc_exe("lua"), enc_exe("luaw")}
local targ_dll = {enc_dll("luaadd")}
local targ_units1 = {"console.c", "consolew.c", "darr.c"}
local targ_units2 = {"additions.c"}

local targ_compile_units1 = check_cache(targ_units1, "src/", "obj/", "o")
local targ_compile_units2 = check_cache(targ_units2, "src/", "obj/", "o")
local targ_end = check_cache({"libluaadd.dll.a"}, "obj/", "obj/", "a")

local exe_test = 
	   check_bin_cache(targ_exe, "src/", install_path .. "\\", targ_units1)
	or check_bin_cache(targ_exe, "src/", install_path .. "\\", targ_units2)
	or check_bin_cache(targ_dll, "src/", install_path .. "\\", targ_units1)
	or check_bin_cache(targ_dll, "src/", install_path .. "\\", targ_units2)



local std_libs = enc_dll(" -llua53") .. choose_opt("", " -lm -ldl", " -lm -ldl")


local targ_luaadd_dll_a = enc_dll("libluaadd") .. ".a"
local targ_luaadd_dll = enc_dll("luaadd")
local targ_luaadd_o = {"additions.o"}
local targ_luaadd_libs = std_libs


local targ_lua_exe = enc_exe("lua")
local targ_lua_exe_o = {"console.o", "darr.o"}
local targ_lua_exe_libs = std_libs .. " -lluaadd.dll"


local targ_luaw_exe = enc_exe("luaw")
local targ_luaw_exe_o = {"consolew.o", "darr.o"}
local targ_lua_exe_libs = std_libs .. " -lluaadd.dll"



-- compile string
local compile_str1 = gcc_c(
		gcc.g,
		gcc.O,
		gcc.warnings,
		gcc.extra_warnings,
		gcc.defines,
		gcc.ccextras,
		gcc.include_dir,
		gcc.library_dir,
		targ_compile_units1)
		
local compile_str2 = gcc_c(
		gcc.g,
		gcc.O,
		gcc.warnings,
		gcc.extra_warnings,
		gcc.defines,
		gcc.ccextras,
		gcc.include_dir,
		gcc.library_dir,
		targ_compile_units2)
		
-- generate dll/so string
local linker_str_dll1 = choose_gcc_dll()(
		targ_luaadd_dll_a,
		gcc.g,
		gcc.O,
		gcc.warnings,
		gcc.extra_warnings,
		gcc.defines,
		gcc.ldextras,
		gcc.include_dir,
		gcc.library_dir,
		targ_luaadd_dll,
		targ_luaadd_o,
		targ_luaadd_libs)


-- lua linker string
local linker_str_exe1 = gcc_l(
		gcc.windows,
		gcc.g,
		gcc.O,
		gcc.warnings,
		gcc.extra_warnings,
		gcc.ldextras,
		gcc.include_dir,
		gcc.library_dir,
		targ_lua_exe,
		targ_lua_exe_o,
		targ_lua_exe_libs)

-- luaw linker string
local linker_str_exe2 = gcc_l(
		gcc.windows,
		gcc.g,
		gcc.O,
		gcc.warnings,
		gcc.extra_warnings,
		gcc.ldextras,
		gcc.include_dir,
		gcc.library_dir,
		targ_luaw_exe,
		targ_luaw_exe_o,
		targ_lua_exe_libs)



-- compile
if(#targ_compile_units1 > 0 or exe_test or force)then
	compiler_exec(targ_dir, compile_str1)
	obj_transfer()
end
if(#targ_compile_units2 > 0 or exe_test or force)then
	compiler_exec(targ_dir, compile_str2)
	obj_transfer()
end


if(#targ_compile_units1 + #targ_compile_units2 > 0 or exe_test or force)then
	-- link dll
	linker_exec(enc_dll("libluaadd") .. ".a" .. enc_dll(" luaadd"), linker_str_dll1)
	obj_transfer()

	-- link exe
	linker_exec("lua", linker_str_exe1)
	linker_exec("luaw", linker_str_exe2)
	
	-- strip redundancy
	if(not gcc.debug)then
		strip_targ(enc_exe("lua"))
		strip_targ(enc_exe("luaw"))
	end
	
	-- setup
	migrate_binaries(install_path, {enc_exe("lua"), enc_exe("luaw"), enc_dll("luaadd")})
end
print("Done. Up to date.")


