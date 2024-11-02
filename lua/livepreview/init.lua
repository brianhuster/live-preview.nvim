---@brief
--- This document is about API from live-preview.nvim, a plugin for live previewing markdown, asciidoc, and html files.
---
--- To work with API from this plugin, require it in your Lua code:
--- ```lua
--- local livepreview = require('livepreview')
--- ```

local M = {}

local server = require("livepreview.server")
local utils = require("livepreview.utils")

M.config = {}
M.serverObj = nil

-- find html/md/adoc buffer
local function find_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if utils.supported_filetype(buf_name) then
				return buf_name
			end
		end
	end
	return nil
end

--- Stop live-preview server
function M.live_stop()
	if M.serverObj then
		M.serverObj:stop()
	end
end

--- Start live-preview server
---@param filepath string: path to the file
---@param port number: port to run the server on
function M.live_start(filepath, port)
	local processes = utils.processes_listening_on_port(port)
	if #processes > 0 then
		for _, process in ipairs(processes) do
			if process.pid ~= vim.uv.os_getpid() then
				if M.config.autokill and not process.name:match("vim") then
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
	M.serverObj = server.Server:new(
		M.config.dynamic_root and vim.fs.dirname(filepath) or nil,
		M.config)
	vim.wait(50, function()
		M.serverObj:start("127.0.0.1", port, function(client)
			if utils.supported_filetype(filepath) == "html" then
				server.websocket.send_json(client, { type = "reload" })
			else
				local content = utils.uv_read_file(filepath)
				local message = {
					type = "update",
					content = content,
				}
				server.websocket.send_json(client, message)
			end
		end)
		return true
	end, 98)
end

--- Setup live preview
--- @param opts {commands: {start: string, stop: string}, port: number, browser: string, sync_scroll: boolean, telescope: {autoload: boolean}}|nil
--- Default options:
--- ```lua
--- {
--- 	commands = {
--- 		start = "LivePreview",
--- 		stop = "StopPreview",
--- 	},
--- 	port = 5500,
--- 	autokill = false,
--- 	browser = "default",
--- 	dynamic_root = false,
--- 	sync_scroll = false,
--- 	telescope = {
--- 		autoload = false,
--- 	}
--- }
--- ```
function M.setup(opts)
	if M.config.commands then
		if M.config.commands.start then
			vim.api.nvim_del_user_command(M.config.commands.start)
		end
		if M.config.commands.stop then
			vim.api.nvim_del_user_command(M.config.commands.stop)
		end
	end

	local default_options = {
		commands = {
			start = "LivePreview",
			stop = "StopPreview",
		},
		autokill = false,
		port = 5500,
		browser = "default",
		dynamic_root = false,
		sync_scroll = false,
		telescope = {
			autoload = false,
		},
	}

	M.config = vim.tbl_deep_extend("force", default_options, opts or {})

	vim.api.nvim_create_user_command(M.config.commands.start, function(cmd_opts)
		local filepath
		if cmd_opts.args ~= "" then
			filepath = cmd_opts.args
			if vim.fn.isabsolutepath(filepath) == 0 then
				filepath = utils.joinpath(vim.uv.cwd(), filepath)
			end
		else
			filepath = vim.api.nvim_buf_get_name(0)
			if not utils.supported_filetype(filepath) then
				filepath = find_buf()
				if not filepath then
					print("live-preview.nvim only supports html, markdown, and asciidoc files")
					return
				end
			end
		end
		utils.open_browser(
			string.format(
				"http://localhost:%d/%s",
				M.config.port,
				vim.fs.basename(filepath) and M.config.dynamic_root or utils.get_base_path(filepath, vim.uv.cwd())
			),
			M.config.browser
		)

		M.live_start(filepath, M.config.port)
	end, {
		nargs = "?",
		complete = "file",
	})

	vim.api.nvim_create_user_command(M.config.commands.stop, function()
		M.live_stop()
		print("Live preview stopped")
	end, {})

	if M.config.telescope.autoload then
		local telescope = require("telescope")
		if telescope then
			telescope.load_extension("livepreview")
		else
			vim.notify_once("telescope.nvim is not installed", vim.log.levels.WARN)
		end
	end
end

---@deprecated
---Use |livepreview.live_stop()| instead
function M.stop_preview()
	vim.deprecate("stop_preview()", "live_stop()", "v1.0.0", "live-preview.nvim")
	M.live_stop()
end

---@deprecated
---Use |livepreview.live_start()| instead
function M.preview_file(filepath, port)
	vim.deprecate("preview_file()", "live_start()", "v1.0.0", "live-preview.nvim")
	M.live_start(filepath, port)
end

return M
