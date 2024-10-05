local l = require("live-preview")

local function read_tags_file()
	local uv_read_file = require("live-preview").utils.uv_read_file
	local tags_file = "doc/tags"
	local tags = uv_read_file(tags_file)
	return tags
end

local function extract_functions(input)
	local functions = {}
	for line in input:gmatch("[^\n]+") do
		-- Sử dụng biểu thức chính quy để tìm các chuỗi phù hợp
		local func_name = line:match("/%*(%S+%b())%s*%*")
		if func_name then
			func_name = func_name:gsub("live%-preview", "l")
			table.insert(functions, func_name)
		end
	end
	return functions
end

-- Gọi hàm để trích xuất các tên hàm
local extracted_functions = extract_functions(read_tags_file())

-- In các hàm đã trích xuất
for _, func in ipairs(extracted_functions) do
	print(func)
end
