---@brief
--- To run health check for Live Preview, do
--- ```vim
--- :checkhealth livepreview
--- ```

local await_term_cmd = require("livepreview.utils").await_term_cmd
---@type string

local M = {}

--- Returns the metadata (pkg.json) of live-preview.nvim as a table.
---@return table|nil
function M.spec()
	local read_file = require("livepreview.utils").uv_read_file
	local get_plugin_path = require("livepreview.utils").get_plugin_path

	local path_to_packspe = vim.fs.joinpath(get_plugin_path(), "pkg.json")
	local body = read_file(path_to_packspe)
	if not body then
		return nil
	end
	return vim.json.decode(body)
end

---@type string
M.supported_nvim_ver_range = M.spec().engines.nvim
---@type table
local nvim_ver_table = vim.version()
---@type string
M.nvim_ver = string.format("%d.%d.%d", nvim_ver_table.major, nvim_ver_table.minor, nvim_ver_table.patch)

--- Check if the version is compatible with the range
--- @param ver string: version to check. Example: "0.10.1"
--- @param range string: range to check against. Example: ">=0.10.0"
--- @return boolean: true if compatible, false otherwise
local function is_compatible(ver, range)
	local requirement = vim.version.range(range)
	return requirement:has(ver)
end

--- Check if the current Nvim version is compatible with Live Preview
--- @return boolean: true if compatible, false otherwise
function M.is_nvim_compatible()
	return is_compatible(M.nvim_ver, M.supported_nvim_ver_range)
end

--- Checkhealth server and port
--- @param port number: port to check
local function checkhealth_port(port)
	local cmd
	if vim.uv.os_uname().version:match("Windows") then
		cmd = string.format(
			[[
			Get-NetTCPConnection -LocalPort %d | Where-Object { $_.State -eq 'Listen' } | ForEach-Object {
				$pid = $_.OwningProcess
				$process = Get-Process -Id $pid -ErrorAction SilentlyContinue
				$process.Id
			}
		]],
			port
		)
	else
		cmd = string.format("lsof -i:%d | grep LISTEN | awk '{print $2}'", port)
	end
	local cmd_result = await_term_cmd(cmd)
	local pid = vim.split(cmd_result.stdout, "\n")[1]

	local function getProcessName(processID)
		local command
		if vim.uv.os_uname().version:match("Windows") then
			command = string.format(
				[[
				Get-Process -Id %d | Select-Object -ExpandProperty Name
			]],
				processID
			)
		else
			command = string.format("ps -p %d -o comm=", processID)
		end
		local result = await_term_cmd(command)
		local name = result.stdout
		if not name or #name == 0 then
			return ""
		else
			return vim.split(name, "\n")[1]
		end
	end
	if not pid or #pid == 0 then
		vim.health.warn("Server is not running at port " .. port)
		return
	else
		if tonumber(pid) == vim.uv.os_getpid() then
			vim.health.ok("Server is healthy on port " .. port)
			local serverObj = require("livepreview").serverObj
			if serverObj and serverObj.webroot then
				vim.health.ok("Server root: " .. serverObj.webroot)
			end
		else
			local process_name = getProcessName(pid)
			vim.health.warn(
				string.format([[The port %d is being used by another process: %s (PID: %s).]], port, process_name, pid),
				"Though live-preview.nvim can automatically kill processes that use the port when you start a Live Preview server, it can not kill other Neovim processes. If another Neovim process is using the port, you should manually close the server run inside that Neovim, or just close that Neovim.")
		end
	end
end

local function check_config()
	local config = require("livepreview").config
	if not config or #config == 0 then
		vim.health.warn("Setup function not called",
			"Please add `require('livepreview').setup()` to your Lua config or `lua require('livepreview').setup()` to your Vimscript config for Nvim")
		return
	else
		vim.health.info(vim.inspect(config))
	end
end

--- Run checkhealth for Live Preview. This can also be called using `:checkhealth livepreview`
function M.check()
	vim.health.start("Check compatibility")
	if not M.is_nvim_compatible() then
		vim.health.error("|live-preview.nvim| requires Nvim " ..
			M.supported_nvim_ver_range .. ", but you are using " .. M.nvim_ver,
			"Please upgrade your Nvim"
		)
	else
		vim.health.ok("Nvim " .. M.nvim_ver .. " is compatible with Live Preview")
	end

	if vim.uv.os_uname().version:match("Windows") then
		if not vim.fn.executable("pwsh") then
			vim.health.warn("PowerShell not available")
		else
			vim.health.ok("PowerShell is available")
		end
	end

	if require("livepreview").config.port then
		vim.health.start("Checkhealth server and process")
		vim.health.ok("This Nvim process's PID is " .. vim.uv.os_getpid())
		checkhealth_port(require("livepreview").config.port)
	end

	vim.health.start("Check your live-preview.nvim config")
	check_config()
end

return M
