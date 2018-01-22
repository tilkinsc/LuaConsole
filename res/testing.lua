
require("luaadd")

if(arg)then
	print(#arg)
end
if({...})then
	print(#{...})
end

-- prints anything in args
for i, v in pairs(arg) do
	print(i, v, type(v))
end

for i, v in pairs({...}) do
	print(i, v, type(v))
end

-- use -Dtest=5 to display use
print(test)

-- error
os.whatever()
