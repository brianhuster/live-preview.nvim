---@brief
--- To run health check for Live Preview, run
--- ```vim
--- :checkhealth livepreview
--- ```
--- This will check if your Neovim version is compatible with Live Preview and if the commands to open browser are available.

local spec = require("livepreview.spec")
local nvim_ver_range = spec().engines.nvim
local nvim_ver_table = vim.version()
local nvim_ver = string.format("%d.%d.%d", nvim_ver_table.major, nvim_ver_table.minor, nvim_ver_table.patch)

local M = {}

--- Check if the version is compatible with the range
--- @param ver string: version to check. Example: "0.10.1"
--- @param range string: range to check against. Example: ">=0.10.0"
--- @return boolean: true if compatible, false otherwise
function M.is_compatible(ver, range)
	local requirement = vim.version.range(range)
	return requirement:has(ver)
end

local function checkhealth_command(cmd)
	if vim.fn.executable(cmd) then
		vim.health.ok(cmd)
	else
		vim.health.warn(cmd .. " not available")
	end
end


--- Run health check for Live Preview. This can also be run using `:checkhealth livepreview`
--- @see https://neovim.io/doc/user/health.html
function M.check()
	vim.health.start("Live Preview Health Check")
	if not M.is_compatible(nvim_ver, nvim_ver_range) then
		vim.health.warn(
			"Live Preview requires Neovim " .. nvim_ver_range .. ", but you are using " .. nvim_ver
		)
	else
		vim.health.ok("Neovim version is compatible with Live Preview")
	end

	vim.health.info("\n")
	vim.health.info(
		"For Live Preview to open default browser, at least one of these commands must be executable. If you have specified a custom browser in your configuration, you can ignore this message.")
	local open_cmds = { "xdg-open", "open", "start", "rundll32", "wslview" }
	for _, cmd in ipairs(open_cmds) do
		checkhealth_command(cmd)
	end
end

return M
