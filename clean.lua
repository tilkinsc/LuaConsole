
-- define v this or use -Dplat=Windows -- Linux -- MacOSX
-- plat = os.types.Windows -- os.types.Linux -- os.types.MacOSX

if(plat == nil)then
	error("Please define plat as Windows Linux or MacOSX")
end


require("build_func")


print(">>> Cleaning bin")
print("> bin\\Debug")
os.execute(rmdir("bin\\Debug"))
os.execute(rmdir("bin\\debug"))
print("> bin\\Release")
os.execute(rmdir("bin\\Release"))
os.execute(rmdir("bin\\release"))


print(">>> Cleaning obj")
print("> *.o")
os.execute(del("*.o"))
os.execute(del("obj\\*.o"))
os.execute(del("src\\*.o"))
print("> *.a")
os.execute(del("*.a"))
os.execute(del("obj\\*.a"))
os.execute(del("src\\*.a"))
print("> *.dll")
os.execute(del("*.dll"))
os.execute(del("obj\\*.dll"))
os.execute(del("src\\*.dll"))

