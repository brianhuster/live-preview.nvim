---@brief
--- Utility functions for live-preview.nvim
--- To require this module, do
--- ```lua
--- local utils = require('livepreview.utils')
--- ```

local M = {}

--- Extract base path from a file path
--- Example: ```lua
--- get_relative_path("/home/user/.config/nvim/lua/livepreview/utils.lua", "/home/user/.config/nvim/")
--- ```
--- will return "lua/livepreview/utils.lua"
---
--- @TODO Use vim.fs.relpath
---
--- @param full_path string
--- @param parent_path string
--- @return string?
function M.get_relative_path(full_path, parent_path)
	full_path = vim.fs.normalize(full_path)
	parent_path = vim.fs.normalize(parent_path)
	if parent_path:sub(-1) ~= "/" then
		parent_path = parent_path .. "/"
	end

	if full_path:sub(1, #parent_path) == parent_path then
		return full_path:sub(#parent_path + 1)
	end
end

--- Check if file name has a supported filetype (html, markdown, asciidoc).
---@param file_name string
---@return string|nil
function M.supported_filetype(file_name)
	local file_name = file_name or ""
	if file_name:match("%.html$") then
		return "html"
	elseif file_name:match("%.md$") or file_name:match("%.markdown$") then
		return "markdown"
	elseif file_name:match("%.adoc$") or file_name:match("%.asciidoc$") then
		return "asciidoc"
	elseif file_name:match("%.svg$") then
		return "svg"
	end
end

--- find a html/md/adoc/svg buffer in buffer list
--- @return string|nil
function M.find_supported_buf()
	local api = vim.api
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			local buf_name = api.nvim_buf_get_name(buf)
			if M.supported_filetype(buf_name) then
				return buf_name
			end
		end
	end
	return nil
end

--- Find supported files in a directory and its subdirectories
--- @param directory string
--- @return table: List of relative paths (compared to `directory`) of the supported files
function M.list_supported_files(directory)
	directory = vim.fn.fnamemodify(directory, ":p")
	local files = vim.fs.find(function(name, _)
		return not not M.supported_filetype(name)
	end, { path = directory, limit = math.huge, type = "file" }) or {}
	local relative_paths = vim.tbl_map(function(file)
		return file and M.get_relative_path(file, directory) or nil
	end, files)
	return relative_paths
end

--- Get the path where live-preview.nvim is installed
--- @return string
function M.get_plugin_path()
	local info = debug.getinfo(1, "S")
	local source = info and info.source
	local full_path = source and source:sub(1, 1) == "@" and source:sub(2)
	local subpath = "lua/livepreview/utils.lua"
	local plugin_path = full_path and full_path:sub(1, -1 - #subpath)
	return plugin_path and vim.fs.normalize(plugin_path)
end

--- Read a file
---@param file_path string
---@return string|nil
function M.read_file(file_path)
	local f = io.open(file_path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

--- Asynchronously read a file
--- @async
--- @param path string: path to the file
--- @param callback function: function to call when the file is read
function M.async_read_file(path, callback)
	local uv = vim.uv
	uv.fs_open(path, "r", 438, function(err_open, fd)
		if err_open or not fd then
			return callback(err_open)
		end
		uv.fs_fstat(fd, function(err_fstat, stat)
			if err_fstat then
				return callback(err_fstat)
			end
			uv.fs_read(fd, stat.size, 0, function(err_read, data)
				callback(err_read, data)
				uv.fs_close(fd)
			end)
		end)
	end)
end

---@return boolean
function M.isWindows()
	return vim.uv.os_uname().version:match("Windows")
end

---@type pwsh|powershell
local powershell_cmd = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"

--- Execute a shell commands
---@async
---@param cmd string: terminal command to execute. Term_cmd will use sh or pwsh depending on the OS
---@param callback function|nil: function to call when the command finishes.
---		- code: the exit code of the command
---		- signal: the signal that killed the process
---		- stdout: the standard output of the command
---		- stderr: the standard error of the command
function M.term_cmd(cmd, callback)
	local shell = "sh"
	if M.isWindows() then
		shell = powershell_cmd
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
---@return {code: number, signal: number, stdout: string, stderr: string}: a table with fields code, stdout, stderr, signal
function M.await_term_cmd(cmd)
	local shell = "sh"
	if M.isWindows() then
		shell = powershell_cmd
	end
	local results = vim.system({ shell, "-c", cmd }, { text = true }):wait()
	return results
end

--- Compute the SHA1 hash of a string.
---@copyright (C) 2007 [Free Software Foundation, Inc](https://fsf.org/).
---@license [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).
---
---@param val string
---@return string: SHA1 hash
function M.sha1(val)
	local bit = bit or require("bit")

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
	path = vim.fn.shellescape(path) or nil
	if path then
		if browser == "default" or browser == nil or #browser == 0 then
			vim.ui.open(path)
		else
			M.term_cmd(browser .. " " .. path)
		end
	end
end

--- Get a list of processes listening on a port
--- @param port number
--- @return {name : string, pid : number}[]|{}: a table with the processes listening on the port (except for the current process), including name and PID
function M.processes_listening_on_port(port)
	local cmd = ("lsof -i:%d | grep LISTEN | awk '{print $1, $2}'"):format(port)
	if vim.uv.os_uname().version:match("Windows") then
		cmd = ([[
			Get-NetTCPConnection -LocalPort %d | Where-Object { $_.State -eq 'Listen' } | ForEach-Object {
				$pid = $_.OwningProcess
				$process = Get-Process -Id $pid -ErrorAction SilentlyContinue
				if ($process) {
					$process.Name + " " + $pid
				}
			}
			]]):format(port)
	end
	local cmd_result = M.await_term_cmd(cmd)
	if not cmd_result then
		print("Error getting processes listening on port " .. port)
		return {}
	end
	if cmd_result.code ~= 0 then
		print("Error getting processes listening on port " .. port .. ": " .. cmd_result.stderr)
		return {}
	end
	local cmd_stdout = cmd_result.stdout
	if not cmd_stdout or cmd_stdout == "" then
		return {}
	end
	local processes = {}
	local lines = vim.split(cmd_stdout, "\n")
	for _, line in ipairs(lines) do
		local parts = vim.split(line, " ")
		local name = parts[1]
		local pid = tonumber(parts[2])
		if name and pid then
			table.insert(processes, { name = name, pid = pid })
		end
	end
	return processes
end

--- Kill a process by PID
--- @param pid number
--- @return boolean: whether the process was killed successfully
function M.kill(pid)
	local success = vim.uv.kill(pid, "sigterm") == 0
	if not success then
		success = vim.uv.kill(pid, "sigkill") == 0
	end
	return success
end

--- Check if a path is absolute
--- @param path string
--- @return boolean
function M.is_absolute_path(path)
	return path:sub(1, 1) == "/" or path:sub(2, 2) == ":"
end

return M
