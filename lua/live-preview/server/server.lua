---@brief Server class for live-preview.nvim

local handler = require("live-preview.server.handler")
local get_plugin_path = require("live-preview.utils").get_plugin_path
local websocket = require("live-preview.server.websocket")

---@class Server
local Server = {}
Server.__index = Server

local uv = vim.uv


--- Constructor
--- @param webroot string: path to the webroot
function Server:new(webroot)
	self.webroot = webroot or "."
	self.server = uv.new_tcp()
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
function Server:start(ip, port)
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
		self:watch_dir(function()
			websocket.send(client, "reload")
		end)
	end)

	print("Server listening on port " .. port)
	uv.run()
end

--- Stop the server
function Server:stop()
	self.server:close()
	self.server = uv.new_tcp()
end

return Server
