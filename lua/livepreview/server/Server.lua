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

--- Send a scroll message to a WebSocket client
--- The message is a table with the following
--- - type: "scroll"
--- - filepath: path to the file
--- - line: top line of the window
--- @param client uv_tcp_t: client
local function send_scroll(client)
	if not need_scroll then
		return
	end
	if not supported_filetype(filepath) or supported_filetype == "html" then
		return
	end
	local message = {
		type = "scroll",
		filepath = filepath or '',
		cursor = vim.api.nvim_win_get_cursor(0),
		length = vim.api.nvim_buf_line_count(0),
	}
	vim.print(message)
	websocket.send_json(client, message)
	need_scroll = false
end


vim.api.nvim_create_autocmd("WinScrolled", {
	callback = function()
		need_scroll = true
		filepath = vim.api.nvim_buf_get_name(0)
		if ws_client then
			send_scroll(ws_client)
		end
	end
})

--- Constructor
--- @param webroot string: path to the webroot
function Server:new(webroot)
	self.server = uv.new_tcp()
	self.webroot = webroot or "."
	return self
end

--- Handle routes
--- @param path string: path from the http request
--- @return string: path to the file
function Server:routes(path)
	local file_path
	if path == '/' then
		path = '/index.html'
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
	local watcher = uv.new_fs_event()
	watcher:start(self.webroot, {}, function(err, filename, event)
		if err then
			print("Watch error: " .. err)
			return
		end
		func()
	end)
end

--- Start the server
--- @param ip string: IP address to bind to
--- @param port number: port to bind to
--- @param func function({client: uv_tcp_t})|nil # Function to call when there is a change in the watched directory
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
