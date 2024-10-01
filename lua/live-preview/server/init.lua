---@brief Server module for live-preview.nvim

local M = {}
M.handler = require('live-preview.server.handler')
M.utils = require('live-preview.server.utils')

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

--- Watch a directory for changes and send a message "reload" to a WebSocket client
function Server:watch_dir()
	local watcher = uv.new_fs_event()
	watcher:start(self.webroot, {}, function(err, filename, event)
		if err then
			vim.print("Watch error: " .. err)
			return
		end
		self:websocket_send("reload")
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
		local request = M.handler.client(client)
		local req_info = M.handler.request(request)
		if req_info then
			local path = req_info.path
			local if_none_match = req_info.if_none_match
			local file_path = M.handler.routes(path)
			M.handler.serve_file(client, file_path, if_none_match)
		end
		self:watch_dir()
	end)

	print("Server listening on port " .. port)
	uv.run()
end

--- Stop the server
function Server:stop()
	self.server:close()
	self.server = uv.new_tcp()
end

M.Server = Server
return M