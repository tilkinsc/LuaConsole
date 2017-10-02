
-- prints anything in args
for i, v in pairs(args) do
	print(i, v, type(v))
end

-- use -Dtest=5 to display use
print(test)

-- error
os.whatever()
