---@brief
--- This document is about API from live-preview.nvim, a plugin for live previewing markdown, asciidoc, and html files.
---
--- Note : these API are under development and may introduce breaking changes in the future.
---
--- To work with API from this plugin, require it in your Lua code:
--- ```lua
--- local livepreview = require('livepreview')
--- ```

local M = {}

local cmd = "LivePreview"
local server = require("livepreview.server")
local utils = require("livepreview.utils")
local config = require("livepreview.config")

M.serverObj = nil

--- Stop live-preview server
function M.close()
	if M.serverObj then
		M.serverObj:stop()
		M.serverObj = nil
	end
end

--- Start live-preview server
---@param filepath string: path to the file
---@param port number: port to run the server on
function M.start(filepath, port)
	local processes = utils.processes_listening_on_port(port)
	if #processes > 0 then
		for _, process in ipairs(processes) do
			if process.pid ~= vim.uv.os_getpid() then
				if config.config.autokill and not process.name:match("vim") then
					utils.kill(process.pid)
				else
					vim.print(
						string.format(
							"Port %d is being used by another process `%s` (PID %d). Run `:lua vim.uv.kill(%d)` to kill it.",
							port,
							process.name,
							process.pid,
							process.pid
						),
						vim.log.levels.WARN
					)
				end
			end
		end
	end
	if M.serverObj then
		M.serverObj:stop()
	end
	M.serverObj = server.Server:new(config.config.dynamic_root and vim.fs.dirname(filepath) or nil)
	vim.wait(50, function()
		local function onTextChanged(client)
			local bufname = vim.api.nvim_buf_get_name(0)
			if not utils.supported_filetype(bufname) or utils.supported_filetype(bufname) == "html" then
				return
			end
			local message = {
				filepath = bufname,
				type = "update",
				content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"),
			}
			server.websocket.send_json(client, message)
		end

		M.serverObj:start("127.0.0.1", port, {
			on_events = utils.supported_filetype(filepath) == "html" and {
				LivePreviewDirChanged = function(client)
					server.websocket.send_json(client, { type = "reload" })
				end,
			} or {
				TextChanged = vim.schedule_wrap(onTextChanged),
				TextChangedI = vim.schedule_wrap(onTextChanged),
			},
		})

		return true
	end, 98)
end

function M.pick()
	local picker = require("livepreview.picker")

	local pick_callback = function(pick_value)
		local filepath = pick_value
		M.start(filepath, config.config.port)
		vim.cmd.edit(filepath)
		utils.open_browser(
			string.format(
				"http://localhost:%d/%s",
				config.config.port,
				config.config.dynamic_root and vim.fs.basename(filepath) or filepath
			),
			config.config.browser
		)
	end

	local picker_funcs = {}
	for k, v in pairs(config.pickers) do
		picker_funcs[v] = picker[k]
	end

	if config.config.picker then
		if not picker_funcs[config.config.picker] then
			vim.notify("Error : picker opt invalid", vim.log.levels.ERROR)
			return
		end
		local status, err = pcall(picker_funcs[config.config.picker], pick_callback)
		if not status then
			vim.notify("live-preview.nvim : error calling picker " .. config.config.picker, vim.log.levels.ERROR)
			vim.notify(err, vim.log.levels.ERROR)
		end
	else
		picker.pick(pick_callback)
	end
end

function M.help()
	local function print_help(text)
		print(text:format(cmd))
	end
	print("live-preview.nvim commands:")
	print_help(
		[[  :%s start [filepath] - Start live-preview server and open browser. If no filepath is given, preview the current buffer.]]
	)
	print_help([[  :%s close - Stop live-preview server]])
	print_help([[  :%s pick - Select a file to preview (using a picker like telescope.nvim, fzf-lua or mini.pick)]])
	print("  :che[ckhealth] livepreview - Check the health of the plugin")
	print("  :h[elp] livepreview - Open the documentation")
end

--- @deprecated Use `require('livepreview.config').set(opts)` instead
function M.setup(opts)
	config.set(opts)
end

return M
