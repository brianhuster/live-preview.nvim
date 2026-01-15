---@brief Server module for live-preview.nvim
---To require this module, do
---```lua
---local server = require('livepreview.server')
---```

local M = {}
local handler = require("livepreview.server.handler")
local get_plugin_path = require("livepreview.utils").get_plugin_path
local websocket = require("livepreview.server.websocket")
local supported_filetype = require("livepreview.utils").supported_filetype
local fswatch = require("livepreview.server.fswatch")
local api = vim.api

---@class FsEvent
---@field change boolean
---@field rename boolean

---@class LivePreviewServer
---To call this class, do
---```lua
---local Server = require('livepreview.server').Server
local Server = {}
Server.__index = Server

local uv = vim.uv
local need_scroll = false
local filepath = ""
M.connecting_clients = {}
local cursor_line
local operating_system = uv.os_uname().sysname

---@class ServerStartOptions
---@field on_events? table<string, function(client:userdata):void>

--- Send a scroll message to a WebSocket client
--- The message is a table with the following
--- - type: "scroll"
--- - filepath: path to the file
--- - line: top line of the window
local function send_scroll()
	local cursor = api.nvim_win_get_cursor(0)
	if cursor_line == cursor[1] then
		return
	end
	if not need_scroll then
		return
	end
	if not supported_filetype(filepath) or supported_filetype(filepath) == "html" then
		return
	end
	local message = {
		type = "scroll",
		filepath = filepath or "",
		cursor = api.nvim_win_get_cursor(0),
	}
	for _, client in ipairs(M.connecting_clients) do
		websocket.send_json(client, message)
	end
	cursor_line = cursor[1]
	need_scroll = false
end

--- Constructor
--- @param webroot string|nil: path to the webroot
function Server:new(webroot)
	self.server = uv.new_tcp()
	self.webroot = webroot or uv.cwd()
	api.nvim_create_augroup("LivePreview", {
		clear = true,
	})

	local config = require("livepreview.config").config
	if config.sync_scroll then
		api.nvim_create_autocmd({
			"WinScrolled",
			"CursorMoved",
			"CursorMovedI",
		}, {
			callback = function()
				need_scroll = true
				filepath = api.nvim_buf_get_name(0)
				if #M.connecting_clients then
					send_scroll()
				end
			end,
		})
	end
	return self
end

--- Handle routes
--- @param path string: path from the http request
--- @return string: path to the file
function Server:routes(path)
	if path == "/" then
		path = "/index.html"
	end
	local plugin_req = "/live-preview.nvim/"
	if path:sub(1, #plugin_req) == plugin_req then
		return vim.fs.joinpath(get_plugin_path(), path:sub(#plugin_req + 1))
	else
		return vim.fs.joinpath(self.webroot, path)
	end
end

--- Watch a directory for changes and trigger an event
function Server:watch_dir()
	local callback = vim.schedule_wrap(
		---@param filename string
		---@param events {change: boolean, rename: boolean}
		function(filename, events)
			api.nvim_exec_autocmds("User", {
				pattern = "LivePreviewDirChanged",
				data = {
					filename = filename,
					events = events,
				},
			})
		end
	)
	local function on_change(err, filename, events)
		if err then
			print("Watch error: " .. err)
			return
		end
		callback(filename, events)
	end
	local function watch(path, recursive)
		local handle = uv.new_fs_event()
		if not handle then
			print("Failed to create fs event")
			return
		end
		handle:start(path, { recursive = recursive }, on_change)
		return handle
	end

	if operating_system == "Windows" or operating_system == "Darwin" then
		watch(self.webroot, true)
	else
		local watcherObj = fswatch.Watcher:new(self.webroot)
		watcherObj:start(function(filename, events)
			callback(filename, events)
		end)
		self._watcher = watcherObj
	end
end

--- Start the server with bind/retry logic
--- @param ip string: IP address to bind to
--- @param port number: port to bind to
--- @param opts ServerStartOptions|table: options:
---   - on_events (table)
---   - max_retries (number) default 5
---   - retry_delay (ms) default 1000
---   - try_next_port (bool) default false (if true, will try port+1, port+2, ...)
function Server:start(ip, port, opts)
	opts = opts or {}
	local on_events = opts.on_events
	local max_retries = opts.max_retries or 5
	local retry_delay = opts.retry_delay or 1000
	local try_next_port = opts.try_next_port or false

	-- schedule-safe notify wrapper
	local notify = vim.schedule_wrap(function(...)
		vim.notify(...)
	end)

	-- set up autocommands for on_events as before
	if on_events then
		if on_events.LivePreviewDirChanged then
			self:watch_dir()
		end
		for k, v in pairs(on_events) do
			if k:match("^LivePreview*") then
				api.nvim_create_autocmd("User", {
					group = "LivePreview",
					pattern = k,
					callback = function(param)
						for _, client in ipairs(M.connecting_clients) do
							v(client, param.data)
						end
					end,
				})
			else
				api.nvim_create_autocmd(k, {
					pattern = "*",
					group = "LivePreview",
					callback = function()
						for _, client in ipairs(M.connecting_clients) do
							v(client)
						end
					end,
				})
			end
		end
	end

	-- retry / bind helper
	local attempt = 0

	local function do_listen()
		-- Capture the current server instance into a local variable.
		-- Use only this local `srv` inside the callbacks to avoid race on self.server = nil.
		local srv = self.server
		if not srv then
			-- nothing to listen on
			return
		end

		-- Listen on the captured server
		local ok_listen, listen_err = pcall(function() srv:listen(128, function(err)
			if err then
				notify("listen error: " .. tostring(err), vim.log.levels.ERROR)
				return
			end

			--- Connect to client
			local client = uv.new_tcp()

			-- Check the captured server variable again before accept
			if not srv then
				pcall(function() client:close() end)
				return
			end

			local ok_accept, accept_err = pcall(function() srv:accept(client) end)
			if not ok_accept then
				notify("accept error: " .. tostring(accept_err), vim.log.levels.ERROR)
				pcall(function() client:close() end)
				return
			end

			-- proceed with handling request
			handler.client(client, function(error, request)
				if error or not request then
					notify(error and error, vim.log.levels.ERROR)
					for i, c in ipairs(M.connecting_clients) do
						if c == client then
							pcall(function() client:close() end)
							table.remove(M.connecting_clients, i)
						end
					end
					return
				else
					local req_info = handler.request(client, request)
					if req_info then
						local path = req_info.path
						local if_none_match = req_info.if_none_match
						local file_path = self:routes(path)
						handler.serve_file(client, file_path, if_none_match)
					end
				end
			end)

			table.insert(M.connecting_clients, client)
		end) end)

		if not ok_listen then
			notify("listen setup failed: " .. tostring(listen_err), vim.log.levels.ERROR)
		end
	end

	local function try_bind(p)
		-- create socket if nil (or recreate)
		if not self.server then
			self.server = uv.new_tcp()
		end

		local ok, bind_err = pcall(function() self.server:bind(ip, p) end)
		if not ok then
			local errstr = tostring(bind_err or "")
			-- message likely contains EADDRINUSE or "address already in use"
			if (errstr:match("address already in use") or errstr:match("EADDRINUSE")) and attempt < max_retries then
				attempt = attempt + 1
				notify(("Port %d busy, retry %d/%d in %dms"):format(p, attempt, max_retries, retry_delay), vim.log.levels.WARN)
				-- close socket and schedule retry
				pcall(function()
					if self.server then
						self.server:close()
					end
				end)
				-- clear the server reference so other code knows it's closed
				self.server = nil
				vim.defer_fn(function()
					local next_p = p
					if try_next_port then
						next_p = p + attempt -- try subsequent ports
					end
					try_bind(next_p)
				end, retry_delay)
				return
			end
			-- non-retryable or retries exhausted
			notify("Failed to bind: " .. errstr, vim.log.levels.ERROR)
			return
		end

		-- bind succeeded -> start listening and run loop
		do_listen()
		-- run uv loop (this blocks until uv.stop() is called somewhere)
		uv.run()
	end

	-- start attempts
	try_bind(port)
end

--- Stop the server
--- @param callback? function: callback to run after the server is stopped
function Server:stop(callback)
	if self.server then
		self.server:close(function()
			self.server = nil
			if callback then
				callback()
			end
		end)
	end
	if self._watcher then
		self._watcher:close()
	end
	self._watcher = nil
	api.nvim_del_augroup_by_name("LivePreview")
end

M.Server = Server
M.handler = require("livepreview.server.handler")
M.utils = require("livepreview.server.utils")
M.websocket = require("livepreview.server.websocket")
M.fswatch = require("livepreview.server.fswatch")
return M
