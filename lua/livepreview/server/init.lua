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
local api = vim.api

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

---@class ServerStartOptions
---@field on_events? table<string, function(client:userdata):void>

--- Send a scroll message to a WebSocket client
--- The message is a table with the following
--- - type: "scroll"
--- - filepath: path to the file
--- - line: top line of the window
local function send_scroll()
	local cursor = api.nvim_win_get_cursor(0)
	if cursor_line == cursor[1] then
		return
	end
	if not need_scroll then
		return
	end
	if not supported_filetype(filepath) or supported_filetype(filepath) == "html" then
		return
	end
	local message = {
		type = "scroll",
		filepath = filepath or "",
		cursor = api.nvim_win_get_cursor(0),
	}
	for _, client in ipairs(connecting_clients) do
		websocket.send_json(client, message)
	end
	cursor_line = cursor[1]
	need_scroll = false
end

--- Constructor
--- @param webroot string|nil: path to the webroot
function Server:new(webroot)
	self.server = uv.new_tcp()
	self.webroot = webroot or uv.cwd()
	local config = require("livepreview.config").config
	if config.sync_scroll then
		api.nvim_create_autocmd({
			"WinScrolled",
			"CursorMoved",
			"CursorMovedI",
		}, {
			callback = function()
				need_scroll = true
				filepath = api.nvim_buf_get_name(0)
				if #connecting_clients then
					send_scroll()
				end
			end,
		})
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
--- @param opts ServerStartOptions: a table with the following fields
--- 	- on_events (table<string, function(client:userdata):void>)
function Server:start(ip, port, opts)
	self.server:bind(ip, port)
	self.server:listen(128, function(err)
		if err then
			print("Listen error: " .. err)
			return
		end

		--- Connect to client
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

		--- Handle on_events
		api.nvim_create_augroup("LivePreview", {
			clear = true,
		})

		local on_events = opts.on_events

		if on_events then
			vim.schedule_wrap(function()
				if on_events.LivePreviewDirChanged then
					self:watch_dir(function()
						api.nvim_exec_autocmds("User", {
							group = "LivePreview",
							pattern = "LivePreviewDirChanged",
						})
					end)
				end

				for k, v in pairs(opts.on_events) do
					if k:match("^LivePreview*") then
						api.nvim_create_autocmd("User", {
							group = "LivePreview",
							pattern = k,
							callback = function()
								v(client)
							end,
						})
					else
						api.nvim_create_autocmd(k, {
							pattern = "*",
							group = "LivePreview",
							callback = function()
								v(client)
							end,
						})
					end
				end
			end)
		end
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
	end
	if self._watcher then
		self._watcher:close()
	end
	api.nvim_del_augroup_by_name("LivePreview")
end

M.Server = Server
M.handler = require("livepreview.server.handler")
M.utils = require("livepreview.server.utils")
M.websocket = require("livepreview.server.websocket")
M.fswatch = require("livepreview.server.fswatch")
return M
