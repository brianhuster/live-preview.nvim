---@brief
--- Live preview for markdown, asciidoc, and html files.
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

--- Stop live preview
function M.stop_preview()
	M.serverObj:stop()
end

--- Start live preview
---@param filepath string: path to the file
---@param port number: port to run the server on
function M.preview_file(filepath, port)
	local processes = utils.processes_listening_on_port(port)
	if #processes > 0 then
		for _, process in ipairs(processes) do
			if process.pid ~= vim.uv.os_getpid() then
				vim.ui.input(
					string.format(
						"Port %d is being used by another process %s (PID : %d). Continue will kill that process (y/n)",
						port,
						process.name,
						process.pid
					),
					function(input)
						if input and vim.trim(input) then
							if input:lower() == "y" then
								vim.uv.kill(process.pid)
							end
						end
					end
				)
				return
			end
		end
	end
	if M.serverObj then
		M.serverObj:stop()
	end
	M.serverObj = server.Server:new(vim.fs.dirname(filepath) and M.config.dynamic_root or nil, M.config)
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
--- 	browser = "default",
--- 	dynamic_root = false,
--- 	sync_scroll = false,
--- 	telescope = {
--- 		autoload = false,
--- 	}
--- }
--- ```
function M.setup(opts)
	local default_options = {
		commands = {
			start = "LivePreview",
			stop = "StopPreview",
		},
		port = 5500,
		browser = "default",
		dynamic_root = false,
		sync_scroll = false,
		telescope = {
			autoload = false,
		},
	}

	M.config = vim.tbl_deep_extend("force", default_options, opts or {})

	vim.api.nvim_create_user_command(M.config.commands.start, function()
		local filepath = vim.fn.expand("%:p")
		if not utils.supported_filetype(filepath) then
			filepath = find_buf()
			if not filepath then
				print("live-preview.nvim only supports html, markdown, and asciidoc files")
				return
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

		M.preview_file(filepath, M.config.port)
	end, {})

	vim.api.nvim_create_user_command(M.config.commands.stop, function()
		M.stop_preview()
		print("Live preview stopped")
	end, {})

	if M.config.telescope.autoload then
		local telescope = require("telescope")
		if not telescope then
			vim.notify_once("telescope.nvim is not installed", vim.log.levels.WARN)
		else
			telescope.load_extension("livepreview")
		end
	end
end

return M
