--[[
	MIT License
 
	Copyright (c) 2017-2018 Cody Tilkins
 
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
 
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]


os.types = {
	Windows = "Windows";
	Linux = "Linux";
	MacOSX = "MacOSX";
}


local tab2arr = function(tab, bolster)
	bolster = bolster and bolster or ""
	local str = ""
	for i, v in pairs(tab)do
		str = str .. (bolster or " ") .. v
	end
	return str
end

local gcc_name = "gcc"


gcc_c = function(g, O, warnings, extrawarn, defines, extra, includesd, librariesd, sources, preprocess)
	local str = gcc_name
		.. (g and (" -g" .. g) or "")
		.. (O and (" -O" .. O) or "")
		.. (type(warnings) == "table" and tab2arr(warnings) or (warnings or ""))
		.. (type(extrawarn) == "table" and tab2arr(extrawarn) or (extrawarn or ""))
		.. (type(defines) == "table" and tab2arr(defines) or (defines or ""))
		.. (type(includesd) == "table" and tab2arr(includesd) or (includesd or ""))
		.. (type(librariesd) == "table" and tab2arr(librariesd) or (librariesd or ""))
		.. (type(extra) == "table" and tab2arr(extra) or (extra or ""))
		.. " -c "
		.. (type(sources) == "table" and tab2arr(sources, " src/") or (sources or ""))
	if(preprocess) then str = preprocess(str) end
	return str
end


gcc_l = function(windows, g, O, warnings, extrawarn, extra, includesd, librariesd, exe_name, objects, libs, preprocess)
	local str = gcc_name
		.. (windows and " -mwindows" or "")
		.. (g and (" -g" .. g) or "0")
		.. (O and (" -O" .. O) or "0")
		.. (type(warnings) == "table" and tab2arr(warnings) or (warnings or ""))
		.. (type(extrawarn) == "table" and tab2arr(extrawarn) or (extrawarn or ""))
		.. (type(includesd) == "table" and tab2arr(includesd) or (includesd or ""))
		.. (type(librariesd) == "table" and tab2arr(librariesd) or (librariesd or ""))
		.. (type(extra) == "table" and tab2arr(extra) or (extra or ""))
		.. " -o " .. exe_name
		.. (type(objects) == "table" and tab2arr(objects, " obj/") or (objects or ""))
		.. (type(libs) == "table" and tab2arr(libs) or (libs or ""))
	if(preprocess) then str = preprocess(str) end
	return str
end

gcc_dll = function(lib_name, g, O, warnings, extrawarn, defines, extra, includesd, librariesd, dll_name, objects, libs, preprocess)
	local str = gcc_name
		.. " -shared"
		.. (lib_name and " -Wl,--out-implib," .. lib_name or "")
		.. (g and (" -g" .. g) or "0")
		.. (O and (" -O" .. O) or "0")
		.. (type(warnings) == "table" and tab2arr(warnings) or (warnings or ""))
		.. (type(extrawarn) == "table" and tab2arr(extrawarn) or (extrawarn or ""))
		.. (type(defines) == "table" and tab2arr(defines) or (defines or ""))
		.. (type(includesd) == "table" and tab2arr(includesd) or (includesd or ""))
		.. (type(librariesd) == "table" and tab2arr(librariesd) or (librariesd or ""))
		.. (type(extra) == "table" and tab2arr(extra) or (extra or ""))
		.. " -o " .. dll_name
		.. (type(objects) == "table" and tab2arr(objects, " obj/") or (objects or ""))
		.. (type(libs) == "table" and tab2arr(libs) or (libs or ""))
	if(preprocess) then str = preprocess(str) end
	return str
end

gcc_so = function(lib_name, g, O, warnings, extrawarn, defines, extra, includesd, librariesd, dll_name, objects, libs, preprocess)
	local str = gcc_name
		.. " -shared"
		.. " -Wl,-E -fPIC"
		.. " -Wl,--out-implib," .. lib_name
		.. (g and (" -g" .. g) or "0")
		.. (O and (" -O" .. O) or "0")
		.. (type(warnings) == "table" and tab2arr(warnings) or (warnings or ""))
		.. (type(extrawarn) == "table" and tab2arr(extrawarn) or (extrawarn or ""))
		.. (type(defines) == "table" and tab2arr(defines) or (defines or ""))
		.. (type(includesd) == "table" and tab2arr(includesd) or (includesd or ""))
		.. (type(librariesd) == "table" and tab2arr(librariesd) or (librariesd or ""))
		.. (type(extra) == "table" and tab2arr(extra) or (extra or ""))
		.. " -o " .. dll_name
		.. (type(objects) == "table" and tab2arr(objects, " obj/") or (objects or ""))
		.. (type(libs) == "table" and tab2arr(libs) or (libs or ""))
	if(preprocess) then str = preprocess(str) end
	return str
end


check_cache = function(target, pref1, pref2, endtype)
	local invalid_cache = {}
	for i, v in next, target do
		local cu = io.mtime(pref1 .. v)
		local obj = io.mtime(pref2 .. v:sub(0,-1 - #endtype) .. endtype)
		if(cu ~= nil)then
			if(obj == nil or cu > obj)then
				table.insert(invalid_cache, v)
			end
		end
	end
	return invalid_cache
end

check_bin_cache = function(binaries, pref1, pref2, target)
	for i, v in next, target do
		for l, g in next, binaries do
			local obj = io.mtime(pref1 .. v)
			local bin = io.mtime(pref2 .. g)
			if(bin == nil or obj > bin)then
				return true
			end
		end
	end
	return false
end


compiler_exec = function(target, str)
	print(">>> Compiling for `" .. target .. "`")
	print(">", str .. "\n")
	os.execute(str)
	print("")
end

linker_exec = function(target, str)
	print(">>> Linking `" .. target .. "`")
	print(">", str .. "\n")
	os.execute(str)
	print("")
end


obj_transfer = function()
	print(">>> Moving object files into `/obj`")
	os.execute(move("*.o", "obj"))
	os.execute(move("*.a", "obj"))
end

strip_targ = function(target)
	print(">>> Stripping `" .. target .. "`")
	os.execute("strip " .. target)
end

migrate_binaries = function(install_path, binaries)
	print(">>> Migrating files to " .. install_path)
	print(">", "Removing old files if any ...")
	os.execute(rmdir(install_path))
	os.execute(mkdir(install_path .. "\\res"))
	print(">", "Injecting new files ...")
	os.execute(copy("dll", install_path))
	os.execute(copy("res", install_path .. "\\res"))
	os.execute(copy("root", install_path))
	for i, v in next, binaries do
		os.execute(move(v, install_path))
	end
end


-- preprocessing
enc_dll = function(a) return a .. (plat == os.types.Windows and ".dll" or ((plat == os.types.Linux or plat == os.types.MacOSX) and ".so" or "")) end
enc_exe = function(a) return a .. (plat == os.types.Windows and ".exe" or "") end
choose_gcc_dll = function() return plat == os.types.Windows and gcc_dll or gcc-so end
choose_opt = function(a, b, c) return plat == os.types.Windows and a or (os.types.Linux and b or (os.types.MacOSX and c or nil)) end


-- core apps
if(squelch == nil)then
	move = function(a, b) return (plat == os.types.Windows and "move /Y %s %s 1>nul 2>nul" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "move %s %s > /dev/null")):format(a, b) end
	ren = move
	mkdir = function(a) return (plat == os.types.Windows and "mkdir %s >nul" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "mkdir %s > /dev/null")):format(a) end
	rmdir = function(a) return (plat == os.types.Windows and "rmdir /S /Q %s >nul" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "rm -f -r %s > /dev/null")):format(a) end
	copy = function(a, b) return (plat == os.types.Windows and "xcopy /Y /E %s %s 1>nul 2>nul" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "cp %s %s > /dev/null")):format(a, b) end
	del = function(a) return (plat == os.types.Windows and "del /Q %s >nul" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "rm -f %s > /dev/null")):format(a) end
else
	-- verbose
	move = function(a, b) return (plat == os.types.Windows and "move /Y %s %s" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "move %s %s")):format(a, b) end
	ren = move
	mkdir = function(a) return (plat == os.types.Windows and "mkdir %s" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "mkdir %s")):format(a) end
	rmdir = function(a) return (plat == os.types.Windows and "rmdir /S /Q %s" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "rm -f -r %s")):format(a) end
	copy = function(a, b) return (plat == os.types.Windows and "xcopy /Y /E %s %s" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "cp %s %s")):format(a, b) end
	del = function(a) return (plat == os.types.Windows and "del /Q %s" or ((plat == os.types.Linux or plat == os.types.MacOSX) and "rm -f %s")):format(a) end
end
