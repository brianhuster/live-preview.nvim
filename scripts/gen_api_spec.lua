local l = require("livepreview")

local function read_tags_file()
	local uv_read_file = require("livepreview").utils.uv_read_file
	local tags_file = "doc/tags"
	local tags = uv_read_file(tags_file)
	return tags
end

local function extract_functions(input)
	local functions = {}
	for line in input:gmatch("[^\n]+") do
		local func_name = line:match("/%*(%S+%b())%*")
		if func_name then
			func_name = func_name:gsub("livepreview", "L")
			table.insert(functions, func_name)
		end
	end
	return functions
end

local functions = extract_functions(read_tags_file())

local content = string.format([[
L = require("livepreview")
local functions = %s
describe("Testing API functions", function()
	for _, func in ipairs(functions) do
		it("should be accessible " .. func, function()
			local status, err = pcall(function()
				local fn = load("return " .. func)
				assert(fn, "Function is not accessible: " .. func)
			end)

			assert(status, err or "unknown error")
		end)
	end
end)
]], vim.inspect(functions))

l.utils.uv_write_file("tests/api_spec.lua", content)
