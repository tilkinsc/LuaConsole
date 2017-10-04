
local build_func = {}

local tab2arr = function(tab, bolster)
	bolseter = bolster and bolster or ""
	local str = ""
	for i, v in pairs(tab)do
		str = str .. (bolseter or " ") .. v
	end
	return str
end

build_func.gcc_c = function(windows, g, O, warnings, extrawarn, extra, defines, includesd, librariesd, sources, preprocess)
	local str = "gcc"
		.. (windows and " -mwindows" or "")
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


build_func.gcc_l = function(windows, g, O, warnings, extrawarn, defines, extra, includesd, librariesd, exe_name, objects, libs, preprocess)
	local str = "gcc"
		.. (windows and " -mwindows" or "")
		.. (g and (" -g" .. g) or "")
		.. (O and (" -O" .. O) or "")
		.. (type(warnings) == "table" and tab2arr(warnings) or (warnings or ""))
		.. (type(extrawarn) == "table" and tab2arr(extrawarn) or (extrawarn or ""))
		.. (type(defines) == "table" and tab2arr(defines) or (defines or ""))
		.. (type(includesd) == "table" and tab2arr(includesd) or (includesd or ""))
		.. (type(librariesd) == "table" and tab2arr(librariesd) or (librariesd or ""))
		.. (type(extra) == "table" and tab2arr(extra) or (extra or ""))
		.. " -o " .. exe_name
		.. (type(objects) == "table" and tab2arr(objects, " obj/") or (objects or ""))
		.. (type(libs) == "table" and tab2arr(libs) or (libs or ""))
	if(preprocess) then str = preprocess(str) end
	return str
end

os.types = {
	Windows = "Windows";
	Linux = "Linux";
}

build_type = os.types.Windows

-- core apps
move = function(a, b) return (build_type == os.types.Windows and "move /Y %s %s >nul" or (build_type == os.types.Linux and "move %s %s > /dev/null")):format(a, b) end
ren = move
mkdir = function(a) return (build_type == os.types.Windows and "mkdir %s >nul" or (build_type == os.types.Linux and "mkdir %s > /dev/null")):format(a) end
rmdir = function(a) return (build_type == os.types.Windows and "rmdir /S /Q %s >nul" or (build_type == os.types.Linux and "rm -f -r %s > /dev/null")):format(a) end
copy = function(a, b) return (build_type == os.types.Windows and "xcopy /Y /E %s %s >nul" or (build_type == os.types.Linux and "cp %s %s > /dev/null")):format(a, b) end
del = function(a) return (build_type == os.types.Windows and "del /Q %s >nul" or (build_type == os.types.Linux and "rm -f %s > /dev/null")):format(a) end

-- verbose core apps
move_v = function(a, b) return (build_type == os.types.Windows and "move /Y %s %s" or (build_type == os.types.Linux and "move %s %s")):format(a, b) end
ren_v = move
mkdir_v = function(a) return (build_type == os.types.Windows and "mkdir %s" or (build_type == os.types.Linux and "mkdir %s")):format(a) end
rmdir_v = function(a) return (build_type == os.types.Windows and "rmdir /S /Q %s" or (build_type == os.types.Linux and "rm -f -r %s")):format(a) end
copy_v = function(a, b) return (build_type == os.types.Windows and "xcopy /Y /E %s %s" or (build_type == os.types.Linux and "cp %s %s")):format(a, b) end
del_v = function(a) return (build_type == os.types.Windows and "del /Q %s" or (build_type == os.types.Linux and "rm -f %s")):format(a) end

return build_func
