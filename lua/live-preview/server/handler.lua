---@brief HTTP handler module for server in live-preview.nvim

local websocket = require('live-preview.server.websocket')
local read_file = require('live-preview.utils').uv_read_file
local supported_filetype = require('live-preview.utils').supported_filetype
local get_plugin_path = require('live-preview.utils').get_plugin_path
local toHTML = require('live-preview.template').toHTML
local handle_body = require('live-preview.template').handle_body
local get_content_type = require('live-preview.server.utils.content_type').get
local generate_etag = require('live-preview.server.utils.etag').generate

local M = {}

--- Send an HTTP response
--- @param client uv_tcp_t: client connection
--- @param status string: for example "200 OK", "404 Not Found", etc.
--- @param content_type string: MIME type of the response
--- @param body string: body of the response
--- @param headers table: (optional) additional headers to include in the response
function M.send_http_response(client, status, content_type, body, headers)
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

	client:write(response)
end

--- Handle an HTTP request
--- If the request is a websocket upgrade request, it will call websocket handshake
--- Otherwise, if it is a GET request, return the path from it
---@param request string: HTTP request
---@return {path: string, if_none_match: string} | nil : path to the file and If-None-Match header
function M.request(request)
	if request:match("Upgrade: websocket") then
		websocket.handshake(client, request)
		return nil
	end
	local path = request:match("GET (.+) HTTP/1.1")
	path = path or '/'

	local if_none_match = request:match("If%-None%-Match: ([^\r\n]+)")

	return {
		path = path,
		if_none_match = if_none_match
	}
end

--- Handle routes
--- @param path string: path from the http request
--- @return string: path to the file
function M.routes(path)
	local file_path
	if path == '/' then
		path = '/index.html'
	end
	if path:match("^/live%-preview%.nvim/") then
		file_path = vim.fs.joinpath(get_plugin_path(), path:sub(20)) -- 19 is the length of '/live-preview.nvim/'
	else
		file_path = vim.fs.joinpath(webroot, path)
	end
	return file_path
end

--- Serve a file to the client
--- @param client uv_tcp_t: client connection
--- @param file_path string: path to the file
function M.serve_file(client, file_path, if_none_match)
	local body = read_file(file_path)
	if not body then
		M.send_http_response(client, '404 Not Found', 'text/plain', "404 Not Found")
		return
	end

	local etag = generate_etag(file_path)

	if (if_none_match and if_none_match == etag) then
		M.send_http_response(client, '304 Not Modified', M.get_content_type(file_path), "", {
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

	M.send_http_response(client, '200 OK', get_content_type(file_path), body, {
		["ETag"] = etag
	})
end

--- Handle a client connection, read the request and send a response
---@param client uv_tcp_t: client connection
---@return string: request from the client
function M.client(client)
	local buffer = ""

	client:read_start(function(err, chunk)
		if err then
			print("Read error: " .. err)
			client:close()
			return
		end

		if chunk then
			buffer = buffer .. chunk
			-- Check if the request is complete
			if buffer:match("\r\n\r\n$") then
				return buffer
			else
				print("Incomplete request")
			end
		else
			client:close()
		end
	end)
end