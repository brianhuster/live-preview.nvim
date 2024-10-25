---@brief Server class for live-preview.nvim
--- To call this class, do
--- ```lua
--- local Server = require('livepreview').server.Server
--- ```

local handler = require("livepreview.server.handler")
local get_plugin_path = require("livepreview.utils").get_plugin_path
local websocket = require("livepreview.server.websocket")
local supported_filetype = require("livepreview.utils").supported_filetype

---@class Server
local Server = {}
Server.__index = Server

local uv = vim.uv
local need_scroll = false
local filepath = ""
local ws_client
local cursor_line

--- Send a scroll message to a WebSocket client
--- The message is a table with the following
--- - type: "scroll"
--- - filepath: path to the file
--- - line: top line of the window
--- @param client uv_tcp_t: client
local function send_scroll(client)
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
	websocket.send_json(client, message)
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
			if ws_client then
				send_scroll(ws_client)
			end
		end,
	})
end

--- Constructor
--- @param webroot string|nil: path to the webroot
--- @param config table|nil: configuration
function Server:new(webroot, config)
	self.server = uv.new_tcp()
	self.webroot = webroot or uv.cwd()
	self.config = config or {}
	if self.config.sync_scroll then
		send_scroll_autocmd()
	end
	return self
end

--- Handle routes
--- @param path string: path from the http request
--- @return string: path to the file
function Server:routes(path)
	local file_path
	if path == "/" then
		path = "/index.html"
	end
	if path:match("^/live%-preview%.nvim/") then
		file_path = vim.fs.joinpath(get_plugin_path(), path:sub(20)) -- 19 is the length of '/live-preview.nvim/'
	else
		file_path = vim.fs.joinpath(self.webroot, path)
	end

	return file_path
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

	local function watch(path)
		local handle = uv.new_fs_event()
		handle:start(path, { recursive = false }, on_change)
		return handle
	end

	local function scan_directory(path)
		local handles = {}
		local req = uv.fs_scandir(path)
		if not req then return handles end

		while true do
			local name, type = uv.fs_scandir_next(req)
			if not name then break end
			local full_path = path .. '/' .. name
			if type == 'directory' then
				table.insert(handles, watch(full_path))
				for _, sub_handle in ipairs(scan_directory(full_path)) do
					table.insert(handles, sub_handle)
				end
			end
		end
		return handles
	end

	local handles = scan_directory(self.webroot)
	table.insert(handles, watch(self.webroot)) -- Include the root directory

	-- Store handles to prevent garbage collection
	self._watch_handles = handles
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
				client:close()
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
			end
		end)
		ws_client = client
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
end

return Server
