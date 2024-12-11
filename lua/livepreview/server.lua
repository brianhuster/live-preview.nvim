---@brief Server module for live-preview.nvim
---To require this module, do
---```lua
---local server = require('livepreview.server')
---```

local M = {}
local handler = require("livepreview.server.handler")
local get_plugin_path = require("livepreview.utils").get_plugin_path
local websocket = require("livepreview.server.websocket")
local supported_filetype = require("livepreview.utils").supported_filetype
local fswatch = require("livepreview.server.fswatch")

---@class Server
---To call this class, do
---```lua
---local Server = require('livepreview.server').Server
local Server = {}
Server.__index = Server

local uv = vim.uv
local need_scroll = false
local filepath = ""
local connecting_clients = {}
local cursor_line
local operating_system = uv.os_uname().sysname

--- Send a scroll message to a WebSocket client
--- The message is a table with the following
--- - type: "scroll"
--- - filepath: path to the file
--- - line: top line of the window
local function send_scroll()
	local cursor = vim.api.nvim_win_get_cursor(0)
	if cursor_line == cursor[1] then
		return
	end
	if not need_scroll then
		return
	end
	if not supported_filetype(filepath) or supported_filetype == "html" then
		return
	end
	local message = {
		type = "scroll",
		filepath = filepath or "",
		cursor = vim.api.nvim_win_get_cursor(0),
	}
	for _, client in ipairs(connecting_clients) do
		websocket.send_json(client, message)
	end
	cursor_line = cursor[1]
	need_scroll = false
end

local function send_scroll_autocmd()
	vim.api.nvim_create_autocmd({
		"WinScrolled",
		"CursorMoved",
		"CursorMovedI",
	}, {
		callback = function()
			need_scroll = true
			filepath = vim.api.nvim_buf_get_name(0)
			if #connecting_clients then
				send_scroll()
			end
		end,
	})
end

--- Constructor
--- @param webroot string|nil: path to the webroot
function Server:new(webroot)
	self.server = uv.new_tcp()
	self.webroot = webroot or uv.cwd()
	local config = require("livepreview.config").config
	if config.sync_scroll then
		send_scroll_autocmd()
	end
	return self
end

--- Handle routes
--- @param path string: path from the http request
--- @return string: path to the file
function Server:routes(path)
	if path == "/" then
		path = "/index.html"
	end
	local plugin_req = "/live-preview.nvim/"
	if path:sub(1, #plugin_req) == plugin_req then
		return vim.fs.joinpath(get_plugin_path(), path:sub(#plugin_req + 1))
	else
		return vim.fs.joinpath(self.webroot, path)
	end
end

--- Watch a directory for changes and send a message "reload" to a WebSocket client
--- @param func function: function to call when a change is detected
function Server:watch_dir(func)
	local function on_change(err, filename, event)
		if err then
			print("Watch error: " .. err)
			return
		end
		func()
	end
	local function watch(path, recursive)
		local handle = uv.new_fs_event()
		if not handle then
			print("Failed to create fs event")
			return
		end
		handle:start(path, { recursive = recursive }, on_change)
		return handle
	end

	if operating_system == "Windows" or operating_system == "Darwin" then
		watch(self.webroot, true)
	else
		local watcherObj = fswatch.Watcher:new(self.webroot)
		watcherObj:start(function(filename, events)
			func()
		end)
		self._watcher = watcherObj
	end
end

--- Start the server
--- @param ip string: IP address to bind to
--- @param port number: port to bind to
--- @param func function|nil: Function to call when there is a change in the watched directory
--- 	- client uv_tcp_t: The uv_tcp client passed to func
function Server:start(ip, port, func)
	self.server:bind(ip, port)
	self.server:listen(128, function(err)
		if err then
			print("Listen error: " .. err)
			return
		end

		local client = uv.new_tcp()
		self.server:accept(client)
		handler.client(client, function(error, request)
			if error then
				print(error)

				return
			end
			if request then
				local req_info = handler.request(client, request)
				if req_info then
					local path = req_info.path
					local if_none_match = req_info.if_none_match
					local file_path = self:routes(path)
					handler.serve_file(client, file_path, if_none_match)
				end
			else
				for i, c in ipairs(connecting_clients) do
					if c == client then
						table.remove(connecting_clients, i)
					end
				end
			end
		end)
		table.insert(connecting_clients, client)
		self:watch_dir(function()
			if func then
				func(client)
			end
		end)
	end)

	print("Server listening on port " .. port)
	print("Webroot: " .. self.webroot)
	uv.run()
end

--- Stop the server
function Server:stop()
	if self.server then
		self.server:close(function()
			print("Server closed")
		end)
		self.server = nil
	end
	if self._watcher then
		self._watcher:close()
		self._watcher = nil
	end
end

M.Server = Server
M.handler = require("livepreview.server.handler")
M.utils = require("livepreview.server.utils")
M.websocket = require("livepreview.server.websocket")
M.fswatch = require("livepreview.server.fswatch")
return M
