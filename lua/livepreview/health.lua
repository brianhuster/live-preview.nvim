---@brief
--- To run health check for Live Preview, run
--- ```vim
--- :checkhealth livepreview
--- ```
--- This will check if your Neovim version is compatible with Live Preview and if the commands to open browser are available.

local spec = require("livepreview.spec")
local await_term_cmd = require("livepreview.utils").await_term_cmd
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

local function checkhealth_port(port)
	local cmd
	if vim.uv.os_uname().version:match("Windows") then
		cmd = string.format([[
			Get-NetTCPConnection -LocalPort %d | Where-Object { $_.State -eq 'Listen' } | ForEach-Object {
				$pid = $_.OwningProcess
				$process = Get-Process -Id $pid -ErrorAction SilentlyContinue
				$process.Id
			}
		]], port)
	else
		cmd = string.format("lsof -i:%d | grep LISTEN | awk '{print $2}'", port)
	end
	local cmd_result = await_term_cmd(cmd)

	local function getProcessName(pid)
		local cmd
		if vim.uv.os_uname().version:match("Windows") then
			cmd = string.format([[
				Get-Process -Id %d | Select-Object -ExpandProperty Name
			]], pid)
		else
			cmd = string.format("ps -p %d -o comm=", pid)
		end
		local name = await_term_cmd(cmd)
		if not name or #name == 0 then
			return nil
		else
			return name
		end
	end

	if not cmd_result or #cmd_result == 0 then
		vim.health.warn("Server is not running at port " .. port)
		return
	else
		if cmd_result == vim.uv.os_getpid() then
			vim.health.ok("Server is running at port " .. port)
		else
			local process_name = getProcessName(cmd_result)
			vim.health.warn(
				string.format [[The port %d is being used by another process: %s (PID: %d). This Neovim's PID is %d]],
				port,
				process_name, cmd_result, vim.uv.os_getpid)
		end
	end
end



--- Run health check for Live Preview. This can also be run using `:checkhealth livepreview`
--- @see https://neovim.io/doc/user/health.html
function M.check()
	vim.health.start("Live Preview Health Check")
	if not M.is_compatible(nvim_ver, nvim_ver_range) then
		vim.health.error(
			"Live Preview requires Neovim " .. nvim_ver_range .. ", but you are using " .. nvim_ver
		)
	else
		vim.health.ok("Neovim is compatible with Live Preview")
	end

	vim.health.info("\n")
	if (require("livepreview").config.port) then
		vim.health.info("Checkhealth server and process")
		vim.health.info("This Nvim process's PID is " .. vim.uv.os_getpid())
		checkhealth_port(require("livepreview").config.port)
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
