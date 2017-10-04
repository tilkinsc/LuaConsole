
local build_func = require("build_func")
require("build_setup")


-- things to compile
local compilation_units = {
	"console.c", "consolew.c", "additions.c"
}


-- compile and link strings
local compiler_string = build_func.gcc_c(
					gcc.windows,
					gcc.g,
					gcc.O,
					gcc.warnings,
					gcc.extra_warnings,
					nil,
					gcc.defines,
					gcc.include_dir,
					gcc.library_dir,
					compilation_units)

local linker_string_1n = "lua.exe"
local linker_string_1w = build_func.gcc_l(
					gcc.windows,
					nil,
					nil,
					gcc.warnings,
					gcc.extra_warnings,
					nil,
					nil,
					gcc.include_dir,
					gcc.library_dir,
					linker_string_1n,
					{"console.o", "additions.o"},
					gcc.libraries)

local linker_string_2n = "luaw.exe"
local linker_string_2w = build_func.gcc_l(
					gcc.windows,
					nil,
					nil,
					gcc.warnings,
					gcc.extra_warnings,
					nil,
					nil,
					gcc.include_dir,
					gcc.library_dir,
					linker_string_2n,
					{"consolew.o", "additions.o"},
					gcc.libraries)

-- compilation
print(">>> Compiling for " .. (gcc.debug and "DEBUG" or "RELEASE"))
print(">", compiler_string)
os.execute(compiler_string)
print(">>> Moving object files into /obj")
os.execute(move("*.o", "obj"))

-- lua.exe
print(">>> Linking " .. linker_string_1n)
print(">", linker_string_1w)
os.execute(linker_string_1w)

-- luaw.exe
print(">>> Linking " .. linker_string_2n)
print(">", linker_string_2w)
os.execute(linker_string_2w)

-- strips redundancy
if(not gcc.debug)then
	print(">>> Stripping .exe's")
	os.execute("strip " .. install_path .. "\\" .. linker_string_1n);
	os.execute("strip " .. install_path .. "\\" .. linker_string_2n);
end

-- Sets up exe to be able to run
print(">>> Migrating files to " .. install_path)
print(">", "Removing old files ...")
os.execute(rmdir_v(install_path))
os.execute(mkdir_v(install_path .. "\\res"))

print(">", "Loading new files in ...")
os.execute(copy_v("dll", install_path))
os.execute(copy_v("res", install_path .. "\\res"))
os.execute(move_v("*.exe", install_path))


