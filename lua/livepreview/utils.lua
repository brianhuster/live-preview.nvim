---@brief
--- Utility functions for live-preview.nvim
--- To require this module, do
--- ```lua
--- local utils = require('livepreview.utils')
--- ```

local M = {}

local uv = vim.uv
local bit = require("bit")

--- Check if file name has a supported filetype (html, markdown, asciidoc). Warning: this function will call a Vimscript function
---@param file_name string
---@return filetype string|nil
function M.supported_filetype(file_name)
	if file_name:match("%.html$") then
		return "html"
	elseif file_name:match("%.md$") or file_name:match("%.markdown$") then
		return "markdown"
	elseif file_name:match("%.adoc$") or file_name:match("%.asciidoc$") then
		return "asciidoc"
	end
end

--- Get the path where live-preview.nvim is installed
function M.get_plugin_path()
	local full_path = M.get_path_lua_file()
	if not full_path then
		return nil
	end
	local subpath = "/lua/livepreview/utils.lua"
	return M.get_parent_path(full_path, subpath)
end

--- Read a file using libuv
---@param file_path string
function M.uv_read_file(file_path)
	local fd = uv.fs_open(file_path, "r", 438) -- 438 is decimal for 0666
	if not fd then
		print("Error opening file: " .. file_path)
		return nil
	end

	local stat = uv.fs_fstat(fd)
	if not stat then
		print("Error getting file info: " .. file_path)
		return nil
	end

	local data = uv.fs_read(fd, stat.size, 0)
	if not data then
		print("Error reading file: " .. file_path)
		return nil
	end

	uv.fs_close(fd)
	return data
end

--- Write a file using libuv
--- @param file_path string
function M.uv_write_file(file_path, data)
	local fd = uv.fs_open(file_path, "w", 438) -- 438 is decimal for 0666
	if not fd then
		print("Error opening file: " .. file_path)
		return
	end

	uv.fs_write(fd, data, 0)
	uv.fs_close(fd)
end

--- Get path of the Lua file where the function is called
---@return string | nil
function M.get_path_lua_file()
	local info = debug.getinfo(2, "S")
	if not info then
		print("Cannot get info")
		return nil
	end
	local source = info.source
	if source:sub(1, 1) == "@" then
		return source:sub(2)
	end
end

--- Get the parent path of a subpath
---
--- Example: ```lua
--- get_parent_path("/home/user/.config/nvim/lua/livepreview/utils.lua", "/lua/livepreview/utils.lua")
--- ```
--- will return "/home/user/.config/nvim"
--- @param full_path string
--- @param subpath string
--- @return string | nil
function M.get_parent_path(full_path, subpath)
	local escaped_subpath = subpath:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
	local pattern = "(.*)" .. escaped_subpath
	local parent_path = full_path:match(pattern)
	return parent_path
end

--- Extract base path from a file path
--- Example: ```lua
--- get_base_path("/home/user/.config/nvim/lua/livepreview/utils.lua", "/home/user/.config/nvim/")
--- ```
--- will return "lua/livepreview/utils.lua"
--- @param full_path string
--- @param parent_path string
--- @return string
function M.get_base_path(full_path, parent_path)
	if parent_path:sub(-1) ~= "/" then
		parent_path = parent_path .. "/"
	end

	if full_path:sub(1, #parent_path) == parent_path then
		return full_path:sub(#parent_path + 1)
	end
end

--- Join paths using the correct separator for the OS
--- @param ... string: paths to join
--- @return string: the joined path
--- example: ```lua
--- joinpath("home", "user", "file.txt") -- returns "home/user/file.txt"
--- joinpath("home", "user", "folder", "../file.txt") -- returns "home/user/file.txt"
--- ```
function M.joinpath(...)
	local parts = { ... }
	local stack = {}

	for _, part in ipairs(parts) do
		for segment in string.gmatch(part, "[^/\\]+") do
			if segment == ".." then
				if #stack > 0 then
					table.remove(stack)
				end
			elseif segment ~= "." then
				table.insert(stack, segment)
			end
		end
	end

	return vim.fs.joinpath(unpack(stack))
end

--- Execute a shell commands
---@param cmd string: terminal command to execute. Term_cmd will use sh or pwsh depending on the OS
---@param callback function|nil: function to call when the command finishes.
---		- code: the exit code of the command
---		- signal: the signal that killed the process
---		- stdout: the standard output of the command
---		- stderr: the standard error of the command
function M.term_cmd(cmd, callback)
	local shell = "sh"
	if uv.os_uname().version:match("Windows") then
		shell = "pwsh"
	end

	local on_exit = function(result)
		local code = result.code
		local signal = result.signal
		local stdout = result.stdout
		local stderr = result.stderr
		if callback then
			callback(code, signal, stdout, stderr)
		end
	end

	vim.system({ shell, "-c", cmd }, { text = true }, on_exit)
end

--- Execute a shell command and wait for the exit
---@param cmd string: terminal command to execute. Term_cmd will use sh or pwsh depending on the OS
---@return table: a table with fields code, stdout, stderr, signal
function M.await_term_cmd(cmd)
	local shell = "sh"
	if uv.os_uname().version:match("Windows") then
		shell = "pwsh"
	end
	local results = vim.system({ shell, "-c", cmd }, { text = true }):wait()
	return results
end

--- Compute the SHA1 hash of a string.
---
--- Copyright (C) 2007 [Free Software Foundation, Inc](https://fsf.org/).
---@param val string
---@return string: SHA1 hash
function M.sha1(val)
	local function to_32_bits_str(number)
		return string.char(bit.band(bit.rshift(number, 24), 255))
			.. string.char(bit.band(bit.rshift(number, 16), 255))
			.. string.char(bit.band(bit.rshift(number, 8), 255))
			.. string.char(bit.band(number, 255))
	end

	local function to_32_bits_number(str)
		return bit.lshift(string.byte(str, 1), 24)
			+ bit.lshift(string.byte(str, 2), 16)
			+ bit.lshift(string.byte(str, 3), 8)
			+ string.byte(str, 4)
	end
	-- Mark message end with bit 1 and pad with bit 0, then add message length
	-- Append original message length in bits as a 64bit number
	-- Note: We don't need to bother with 64 bit lengths so we just add 4 to
	-- number of zeros used for padding and append a 32 bit length instead
	local padded_message = val
		.. string.char(128)
		.. string.rep(string.char(0), 64 - ((string.len(val) + 1 + 8) % 64) + 4)
		.. to_32_bits_str(string.len(val) * 8)

	-- Blindly implement method 1 (section 6.1) of the spec without
	-- understanding a single thing
	local H0 = 0x67452301
	local H1 = 0xEFCDAB89
	local H2 = 0x98BADCFE
	local H3 = 0x10325476
	local H4 = 0xC3D2E1F0

	-- For each block
	for block_start = 0, string.len(padded_message) - 1, 64 do
		local block = string.sub(padded_message, block_start + 1)
		local words = {}
		-- Initialize 16 first words
		local i = 0
		for W = 1, 64, 4 do
			words[i] = to_32_bits_number(string.sub(block, W))
			i = i + 1
		end

		-- Initialize the rest
		for t = 16, 79, 1 do
			words[t] = bit.rol(bit.bxor(words[t - 3], words[t - 8], words[t - 14], words[t - 16]), 1)
		end

		local A = H0
		local B = H1
		local C = H2
		local D = H3
		local E = H4

		-- Compute the hash
		for t = 0, 79, 1 do
			local TEMP
			if t <= 19 then
				TEMP = bit.bor(bit.band(B, C), bit.band(bit.bnot(B), D)) + 0x5A827999
			elseif t <= 39 then
				TEMP = bit.bxor(B, C, D) + 0x6ED9EBA1
			elseif t <= 59 then
				TEMP = bit.bor(bit.bor(bit.band(B, C), bit.band(B, D)), bit.band(C, D)) + 0x8F1BBCDC
			elseif t <= 79 then
				TEMP = bit.bxor(B, C, D) + 0xCA62C1D6
			end
			TEMP = (bit.rol(A, 5) + TEMP + E + words[t])
			E = D
			D = C
			C = bit.rol(B, 30)
			B = A
			A = TEMP
		end

		-- Force values to be on 32 bits
		H0 = (H0 + A) % 0x100000000
		H1 = (H1 + B) % 0x100000000
		H2 = (H2 + C) % 0x100000000
		H3 = (H3 + D) % 0x100000000
		H4 = (H4 + E) % 0x100000000
	end

	return to_32_bits_str(H0) .. to_32_bits_str(H1) .. to_32_bits_str(H2) .. to_32_bits_str(H3) .. to_32_bits_str(H4)
end

--- Open URL in the browser
---
--- Example: ```lua
--- open_browser("https://neovim.io/", "firefox")
--- open_browser("https://neovim.io/", "flatpak run com.microsoft.Edge")
--- ```
--- @param path string
--- @param browser string|nil
function M.open_browser(path, browser)
	if browser == "default" or #browser == 0 or browser == nil then
		vim.ui.open(path)
	else
		M.term_cmd(browser .. " " .. path)
	end
end

--- Kill a process which is not Neovim running on a port
--- @param port number
function M.kill_port(port)
	local cmd
	if vim.uv.os_uname().version:match("Windows") then
		cmd = string.format(
			[[
            Get-NetTCPConnection -LocalPort %d | Where-Object { $_.State -eq 'Listen' } | ForEach-Object {
                $pid = $_.OwningProcess
                $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                if ($process -and ($process.Name -notmatch 'vim')) {
                    $process.Id
                }
            }
        ]],
			port
		)
	else
		cmd = string.format("lsof -i:%d | grep LISTEN | grep -v -e 'vim' | awk '{print $2}'", port)
	end
	local cmd_result = M.await_term_cmd(cmd)
	if not cmd_result then
		print("Error killing port " .. port)
		return
	end
	if cmd_result.code ~= 0 then
		print("Error killing port " .. port .. ": " .. cmd_result.stderr)
		return
	end
	local cmd_stdout = cmd_result.stdout
	if not cmd_stdout or cmd_stdout == "" then
		return
	end
	local pids = vim.split(cmd_stdout, "\n")
	for _, pid in ipairs(pids) do
		local pid_number = tonumber(pid)
		if pid_number and pid_number ~= vim.uv.os_getpid() then
			vim.uv.kill(pid_number, 9) -- 9 is the signal number for SIGKILL
		end
	end
end

return M
