---@brief Server module for live-preview.nvim

---@class Server
local Server = {}
Server.__index = Server

local uv = vim.uv
local read_file = require('live-preview.utils').uv_read_file
local sha1 = require('live-preview.utils').sha1
local supported_filetype = require('live-preview.utils').supported_filetype
local get_plugin_path = require('live-preview.utils').get_plugin_path
local toHTML = require('live-preview.template').toHTML
local handle_body = require('live-preview.template').handle_body

--- Constructor
--- @param webroot string: path to the webroot
function Server:new(webroot)
	self.webroot = webroot or "."
	self.server = uv.new_tcp()
	return self
end

--- Generate an ETag for a file
--- The Etag is generated based on the modification time of the file
--- @param file_path string: path to the file
--- @return string: ETag
function Server:generate_etag(file_path)
	local attr = uv.fs_stat(file_path)
	if not attr then
		return nil
	end
	local modification_time = attr.mtime
	return modification_time.sec .. "." .. modification_time.nsec
end

--- Get the content type of a file
--- @param file_path string: path to the file
--- @return string: content type
function Server:get_content_type(file_path)
	if supported_filetype(file_path) then
		return 'text/html'
	elseif file_path:match("%.css$") then
		return 'text/css'
	elseif file_path:match("%.js$") then
		return 'application/javascript'
	elseif file_path:match("%.png$") then
		return 'image/png'
	elseif file_path:match("%.jpg$") or file_path:match("%.jpeg$") then
		return 'image/jpeg'
	elseif file_path:match("%.gif$") then
		return 'image/gif'
	else
		return 'application/octet-stream'
	end
end

--- Send an HTTP response to the client
--- @param status string: HTTP status code
--- @param content_type string: HTTP content type
--- @param body string: response body
--- @param headers table: response headers
function Server:send_http_response(status, content_type, body, headers)
	local response = "HTTP/1.1 " .. status .. "\r\n" ..
		"Content-Type: " .. content_type .. "\r\n" ..
		"Content-Length: " .. #body .. "\r\n" ..
		"Connection: close\r\n"

	if headers then
		for k, v in pairs(headers) do
			response = response .. k .. ": " .. v .. "\r\n"
		end
	end

	response = response .. "\r\n" .. body
	self.client:write(response)
end

--- Handle an HTTP request
--- @param client uv.TCP: client connection
--- @param request string: HTTP request
function Server:handle_request(client, request)
	local file_path
	if request:match("Upgrade: websocket") then
		self:websocket_handshake(client, request)
		return
	end

	local path = request:match("GET (.+) HTTP/1.1")
	path = path or '/'
	if path == '/' then
		path = '/index.html'
	end
	if path:match("^/live%-preview%.nvim/") then
		file_path = vim.fs.joinpath(get_plugin_path(), path:sub(20))
	else
		file_path = vim.fs.joinpath(self.webroot, path)
	end
	local body = read_file(file_path)
	if not body then
		self:send_http_response('404 Not Found', 'text/plain', "404 Not Found")
		return
	end

	local etag = self:generate_etag(file_path)
	local if_none_match = request:match("If%-None%-Match: ([^\r\n]+)")

	if (if_none_match and if_none_match == etag) then
		self:send_http_response('304 Not Modified', self:get_content_type(file_path), "", {
			["ETag"] = etag,
		})
		return
	end

	local filetype = supported_filetype(file_path)
	if filetype then
		if filetype ~= "html" then
			body = toHTML(body, filetype)
		else
			body = handle_body(body)
		end
	end

	self:send_http_response('200 OK', self:get_content_type(file_path), body, {
		["ETag"] = etag
	})
end

--- Handle a client connection
function Server:handle_client()
	local buffer = ""

	self.client:read_start(function(err, chunk)
		if err then
			print("Read error: " .. err)
			client:close()
			return
		end

		if chunk then
			buffer = buffer .. chunk
			if buffer:match("\r\n\r\n$") then
				self:handle_request(client, buffer)
			else
				print("Incomplete request")
			end
		else
			self.client:close()
		end
	end)
end

--- Handle a WebSocket handshake request
--- @param request string: client request
function Server:websocket_handshake(request)
	local key = request:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
	if not key then
		vim.print("Invalid WebSocket request from client")
		self.client:close()
		return
	end

	local accept = sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
	accept = vim.base64.encode(accept)
	accept = vim.trim(accept)

	local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
		"Upgrade: websocket\r\n" ..
		"Connection: Upgrade\r\n" ..
		"Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
	self.client:write(response)
end

--- Send a message to a WebSocket client
--- @param message string: message to send
function Server:websocket_send(message)
	local frame = string.char(0x81) .. string.char(#message) .. message
	self.client:write(frame)
end

--- Watch a directory for changes and send a message "reload" to a WebSocket client
--- @param dir string: path to the directory
--- @param client uv.TCP: WebSocket client
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

		self.client = uv.new_tcp()
		self.server:accept(self.client)
		self:handle_client()
		self:watch_dir()
	end)

	vim.print("Server listening on port " .. port)
	uv.run()
end

--- Stop the server
function Server:stop()
	self.server:close()
	self.server = uv.new_tcp()
end

return Server
