---@brief
--- To run health check for Live Preview, do
--- ```vim
--- :checkhealth livepreview
--- ```

local utils = require("livepreview.utils")

local M = {}

--- Returns the metadata (pkg.json) of live-preview.nvim as a table.
---@return table|nil
function M.spec()
	local read_file = require("livepreview.utils").read_file
	local get_plugin_path = require("livepreview.utils").get_plugin_path

	local path_to_packspec = vim.fs.joinpath(get_plugin_path(), "pkg.json")
	local body = read_file(path_to_packspec)
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
	return requirement and requirement:has(ver) or false
end

--- Check if the current Nvim version is compatible with Live Preview
--- @return boolean: true if compatible, false otherwise
function M.is_nvim_compatible()
	return is_compatible(M.nvim_ver, M.supported_nvim_ver_range)
end

--- Checkhealth server and port
--- @param port number: port to check
local function checkhealth_port(port)
	local processes = utils.processes_listening_on_port(port)
	if not processes or #processes == 0 then
		vim.health.warn("Server is not running at port " .. port)
		return
	else
		for _, process in ipairs(processes) do
			if tonumber(process.pid) == vim.uv.os_getpid() then
				vim.health.ok("Server is healthy on port " .. port)
				local serverObj = require("livepreview").serverObj
				if serverObj and serverObj.webroot then
					vim.health.ok("Server root: " .. serverObj.webroot)
				end
			else
				vim.health.warn(
					string.format(
						[[The port %d is being used by another process `%s` (PID: %d).]],
						port,
						process.name,
						process.pid
					),
					string.format([[You can run `:lua vim.uv.kill(%d)` to kill it.]], process.pid)
				)
			end
		end
	end
end

---@TODO: Will check if the config is valid (only has valid keys)
local function check_config()
	local config = require("livepreview.config").config
	vim.health.info(vim.inspect(config))
end

--- Run checkhealth for Live Preview. This can also be called using `:checkhealth livepreview`
function M.check()
	vim.health.start("Check dependencies")
	if not M.is_nvim_compatible() then
		vim.health.error(
			"|live-preview.nvim| requires Nvim " .. M.supported_nvim_ver_range .. ", but you are using " .. M.nvim_ver,
			"Please upgrade your Nvim"
		)
	else
		vim.health.ok("Nvim " .. M.nvim_ver .. " is compatible with Live Preview")
	end
	-- Check if sh or pwsh is available
	local shell = vim.uv.os_uname().sysname:match("Windows") and "powershell" or "sh"
	if not vim.fn.executable(shell) then
		vim.health.error(
			string.format("`%s` is not available", shell),
			"Please make sure it is installed and available in your PATH"
		)
	else
		vim.health.ok(string.format("`%s` is available", shell))
	end

	for _, dep in pairs(require('livepreview.config').pickers) do
		local ok, _ = pcall(require, dep)
		if not ok then
			vim.health.warn(string.format("`%s` (optional) is not installed", dep))
		else
			vim.health.ok(string.format("`%s` is installed", dep))
		end
	end

	if require("livepreview.config").config.port then
		vim.health.start("Checkhealth server and process")
		vim.health.ok("This Nvim process's PID is " .. vim.uv.os_getpid())
		checkhealth_port(require("livepreview.config").config.port)
	end

	vim.health.start("Check your live-preview.nvim config")
	check_config()
end

return M
