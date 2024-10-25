---@brief WebSocket server implementation
--- To require this module, do
--- ```lua
--- local websocket = require('livepreview.server.websocket')
--- ```

local sha1 = require("livepreview.utils").sha1

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

	local response = "HTTP/1.1 101 Switching Protocols\r\n"
		.. "Upgrade: websocket\r\n"
		.. "Connection: Upgrade\r\n"
		.. "Sec-WebSocket-Accept: "
		.. accept
		.. "\r\n\r\n"
	client:write(response)
end

--- Send a message to a WebSocket client
--- @param client uv_tcp_t: client
--- @param message string: message to send
function M.send(client, message)
	local byteMessage = message
	local length = #byteMessage

	local frame = string.char(0x81)

	if length <= 125 then
		frame = frame .. string.char(length) .. byteMessage
	elseif length <= 65535 then
		frame = frame .. string.char(126) .. string.char(bit.rshift(length, 8), length % 256) .. byteMessage
	else
		frame = frame
			.. string.char(127)
			.. string.char(
				bit.rshift(length, 56),
				bit.rshift(length, 48) % 256,
				bit.rshift(length, 40) % 256,
				bit.rshift(length, 32) % 256,
				bit.rshift(length, 24) % 256,
				bit.rshift(length, 16) % 256,
				bit.rshift(length, 8) % 256,
				length % 256
			)
			.. byteMessage
	end

	client:write(frame)
end

--- Send a JSON message to a WebSocket client
--- @param client uv_tcp_t: client
--- @param message table: message to send
function M.send_json(client, message)
	local json = vim.json.encode(message)
	M.send(client, json)
end

return M
