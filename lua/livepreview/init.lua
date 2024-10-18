---@brief
--- Live preview for markdown, asciidoc, and html files.
---
--- To work with API from this plugin, require it in your Lua code:
--- ```lua
--- local livepreview = require('livepreview')
--- ```

local M = {}

M.server = require("livepreview.server")
M.utils = require("livepreview.utils")
M.spec = require("livepreview.spec")
M.health = require("livepreview.health")
M.template = require("livepreview.template")

local server

local default_options = {
	commands = {
		start = "LivePreview",
		stop = "StopPreview",
	},
	port = 5500,
	browser = "default",
}


local function find_buf() -- find html/md buffer
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if M.utils.supported_filetype(buf_name) then
				return buf_name
			end
		end
	end
	return nil
end

--- Stop live preview
function M.stop_preview()
	server:stop()
end

--- Start live preview
---@param filepath string: path to the file
---@param port number: port to run the server on
function M.preview_file(filepath, port)
	M.utils.kill_port(port)
	if server then
		server:stop()
	end
	server = M.server.Server:new(vim.fs.dirname(filepath))
	vim.wait(50, function()
		server:start("127.0.0.1", port, function(client)
			if M.utils.supported_filetype(filepath) == 'html' then
				M.server.websocket.send_json(client, { type = "reload" })
			else
				local content = M.utils.uv_read_file(filepath)
				M.server.websocket.send_json(client, { type = "update", content = content })
			end
		end)
	end, 99)
end

--- Setup live preview
--- @param opts {commands: {start: string, stop: string}, port: number, browser: string}
---  	- commands: {start: string, stop: string} - commands to start and stop live preview
---  		(default: {start = "LivePreview", stop = "StopPreview"})
---  	- port: number - port to run the server on (default: 5500)
---  	- browser: string - browser to open the preview in (default: "default"). The "default" value will open the preview in system default browser.
function M.setup(opts)
	opts = vim.tbl_deep_extend("force", default_options, opts or {})

	vim.api.nvim_create_user_command(opts.commands.start, function()
		local filepath = vim.fn.expand('%:p')
		if not M.utils.supported_filetype(filepath) then
			filepath = find_buf()
			if not filepath then
				print("live-preview.nvim only supports html, markdown, and asciidoc files")
				return
			end
		end
		M.utils.open_browser(
			string.format(
				"http://localhost:%d/%s",
				opts.port,
				vim.fs.basename(filepath)
			),
			opts.browser
		)

		M.preview_file(filepath, opts.port)
	end, {})

	vim.api.nvim_create_user_command(opts.commands.stop, function()
		M.stop_preview()
		print("Live preview stopped")
	end, {})
end

return M
