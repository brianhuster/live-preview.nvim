---@brief WebSocket server implementation
--- To require this module, do ```lua
---
--- local websocket = require('live-preview.server.websocket')
--- 
--- ```

local sha1 = require('live-preview.utils').sha1

local M = {}

--- Handle a WebSocket handshake request
--- @param client uv_tcp_t: client
--- @param request string: client request
function M.handshake(client, request)
	local key = request:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
	if not key then
		vim.print("Invalid WebSocket request from client")
		client:close()
		return nil
	end

	local accept = sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
	accept = vim.base64.encode(accept)
	accept = vim.trim(accept)

	local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
		"Upgrade: websocket\r\n" ..
		"Connection: Upgrade\r\n" ..
		"Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
	client:write(response)
end

--- Send a message to a WebSocket client
--- @param client uv_tcp_t: client
--- @param message string: message to send
function M.send(client, message)
	local frame = string.char(0x81) .. string.char(#message) .. message
	client:write(frame)
end

return M
