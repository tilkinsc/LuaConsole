
local build_func = require("build_func")
require("build_setup")

print(">>> Cleaning bin")
os.execute(rmdir("bin\\Debug"))
os.execute(rmdir("bin\\Release"))

print(">>> Cleaning obj")
os.execute(rmdir("obj"))
os.execute(mkdir("obj"))
