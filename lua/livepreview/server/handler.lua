---@brief HTTP handler module for server in live-preview.nvim
--- To require this module, do
--- ```lua
--- local handler = require('livepreview.server.handler')
--- ```

local websocket = require("livepreview.server.websocket")
local read_file = require("livepreview.utils").async_read_file
local supported_filetype = require("livepreview.utils").supported_filetype
local toHTML = require("livepreview.template").toHTML
local handle_body = require("livepreview.template").handle_body
local dir2html = require("livepreview.template").dir2html
local get_content_type = require("livepreview.server.utils.content_type").get
local generate_etag = require("livepreview.server.utils.etag").generate

local M = {}

--- Send an HTTP response
--- @param client uv_tcp_t: client connection
--- @param status string: for example "200 OK", "404 Not Found", etc.
--- @param content_type string: MIME type of the response
--- @param body string: body of the response
--- @param headers table|nil: (optional) additional headers to include in the response
function M.send_http_response(client, status, content_type, body, headers)
	local response = "HTTP/1.1 "
		.. status
		.. "\r\n"
		.. "Content-Type: "
		.. content_type
		.. "\r\n"
		.. "Content-Length: "
		.. #body
		.. "\r\n"
		.. "Connection: close\r\n"

	if headers then
		for k, v in pairs(headers) do
			response = response .. k .. ": " .. v .. "\r\n"
		end
	end

	response = response .. "\r\n" .. body

	client:write(response)

	-- M.client has already called read_stop(), so the EOF branch that would
	-- close this socket can never fire: without an explicit close every request
	-- leaks a descriptor in CLOSE_WAIT until the process hits EMFILE.
	-- shutdown() rather than close() so the queued body is not truncated.
	if not client:is_closing() then
		client:shutdown(function()
			if not client:is_closing() then
				client:close()
			end
		end)
	end
end

--- Handle an HTTP request
--- If the request is a websocket upgrade request, it will call websocket handshake
--- Otherwise, if it is a GET request, return the path from it
---@param request string: HTTP request
---@return {path: string, if_none_match: string, accept: string} | nil : path to the file and If-None-Match header
function M.request(client, request)
	if request:match("Upgrade: websocket") then
		websocket.handshake(client, request)
		return
	end
	local path = request:match("GET ([^%s]+) HTTP/1.1")
	local path_decoded = path and vim.uri_decode(path) or "/"

	local if_none_match = request:match("If%-None%-Match: ([^\r\n]+)")
	local accept = request:match("Accept: ([^\r\n]+)") or ""

	return {
		path = path_decoded,
		if_none_match = if_none_match,
		accept = accept,
	}
end

--- Serve a file to the client
--- @param client uv_tcp_t: client connection
--- @param file_path string: path to the file
--- @param if_none_match string|nil: If-None-Match header value
--- @param accept string|nil: Accept header value
function M.serve_file(client, file_path, if_none_match, accept)
	read_file(file_path, function(_, body)
		if not body then
			M.send_http_response(client, "404 Not Found", "text/plain", "404 Not Found")
			return
		end

		local etag = generate_etag(file_path)

		if if_none_match and if_none_match == etag then
			M.send_http_response(client, "304 Not Modified", get_content_type(file_path) or "", "", {
				["ETag"] = etag,
			})
			return
		end

		local filetype = supported_filetype(file_path)
		local content_type = get_content_type(file_path) or ""

		-- Only convert to HTML if the client accepts text/html
		-- This prevents converting SVG files that are referenced by <img> tags
		local accepts_html = accept and accept:match("text/html")
		if filetype and accepts_html then
			if filetype ~= "html" then
				body = toHTML(body, filetype)
			else
				body = handle_body(body)
			end
			content_type = "text/html; charset=UTF-8"
		end

		M.send_http_response(client, "200 OK", content_type, body, {
			["ETag"] = etag,
		})
	end)
end

--- Serve a directory to the client: its index.html if it has one, otherwise a
--- listing of its entries
--- @param client uv_tcp_t: client connection
--- @param dir_path string: path to the directory
--- @param url_path string: path of the directory in the request
--- @param if_none_match string|nil: If-None-Match header value
--- @param accept string|nil: Accept header value
function M.serve_dir(client, dir_path, url_path, if_none_match, accept)
	-- Without the trailing slash, relative links in the page would resolve
	-- against the parent directory
	if url_path:sub(-1) ~= "/" then
		M.send_http_response(client, "302 Found", "text/plain", "", {
			["Location"] = vim.uri_encode(url_path .. "/"),
		})
		return
	end

	local index = vim.fs.joinpath(dir_path, "index.html")
	if vim.uv.fs_stat(index) then
		M.serve_file(client, index, if_none_match, accept)
		return
	end

	local entries = {}
	for name, type in vim.fs.dir(dir_path) do
		if name:sub(1, 1) ~= "." then
			-- Follow symlinks, so that linked directories are listed as directories
			if type == "link" then
				local stat = vim.uv.fs_stat(vim.fs.joinpath(dir_path, name))
				type = stat and stat.type
			end
			table.insert(entries, { name = name, is_dir = type == "directory" })
		end
	end
	table.sort(entries, function(a, b)
		if a.is_dir ~= b.is_dir then
			return a.is_dir
		end
		return a.name:lower() < b.name:lower()
	end)

	M.send_http_response(client, "200 OK", "text/html; charset=UTF-8", dir2html(url_path, entries))
end

--- Handle a client connection, read the request and send a response
---@param client uv_tcp_t: client connection
---@param callback function(): callback function to handle the result
---    - `err`: Error message, if any (nil if no error)
---    - `data`: Request from the client
---@return string: request from the client
function M.client(client, callback)
	local buffer = ""

	client:read_start(function(err, chunk)
		if err or not chunk then
			-- A read error comes with a nil chunk, so falling through to the
			-- EOF branch would close the socket a second time and raise.
			if not client:is_closing() then
				client:close()
			end
			if err then
				callback(err, nil)
			end
			return
		end

		buffer = buffer .. chunk
		if buffer:match("\r\n\r\n$") then
			client:read_stop()
			callback(nil, buffer)
		end
	end)
end

return M
