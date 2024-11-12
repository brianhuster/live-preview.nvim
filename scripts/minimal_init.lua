local dirname = vim.fs.dirname

local function get_path_lua_file()
	local info = debug.getinfo(2, "S")
	if not info then
		print("Cannot get info")
		return ""
	end
	local source = info.source
	if source:sub(1, 1) == "@" then
		return source:sub(2)
	end
end

vim.opt.rtp:append(dirname(dirname(get_path_lua_file())))
