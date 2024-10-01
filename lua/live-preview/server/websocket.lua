---@brief WebSocket server implementation

local M={}


--- Handle a WebSocket handshake request
--- @param client uv_tcp_t: client
--- @param request string: client request
--- @return string | nil: WebSocket response
function M.handshake(client, request)
	local key = request:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
	if not key then
		vim.print("Invalid WebSocket request from client")
		self.client:close()
		return nil
	end

	local accept = sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
	accept = vim.base64.encode(accept)
	accept = vim.trim(accept)

	local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
		"Upgrade: websocket\r\n" ..
		"Connection: Upgrade\r\n" ..
		"Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
	self.client:write(response)
	return response
end

--- Send a message to a WebSocket client
--- @param client uv_tcp_t: client
--- @param message string: message to send
--- @return string: WebSocket frame
function M.send(client, message)
	local frame = string.char(0x81) .. string.char(#message) .. message
	client:write(frame)
	return frame
end

return M
