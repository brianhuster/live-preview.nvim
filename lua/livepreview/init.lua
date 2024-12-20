---@brief
--- This document is about API from live-preview.nvim, a plugin for live previewing markdown, asciidoc, and html files.
---
--- Note : these API are under development and may introduce breaking changes in the future.
---
--- To work with API from this plugin, require it in your Lua code:
--- ```lua
--- local livepreview = require('livepreview')
--- ```

local M = {}

local server = require("livepreview.server")
local utils = require("livepreview.utils")
local config = require("livepreview.config")
local picker = require("livepreview.picker")

M.serverObj = nil

-- find html/md/adoc buffer
local function find_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if utils.supported_filetype(buf_name) then
				return buf_name
			end
		end
	end
	return nil
end

--- Stop live-preview server
function M.close()
	if M.serverObj then
		M.serverObj:stop()
	end
end

--- Start live-preview server
---@param filepath string: path to the file
---@param port number: port to run the server on
function M.start(filepath, port)
	local processes = utils.processes_listening_on_port(port)
	if #processes > 0 then
		for _, process in ipairs(processes) do
			if process.pid ~= vim.uv.os_getpid() then
				if config.config.autokill and not process.name:match("vim") then
					utils.kill(process.pid)
				else
					vim.print(
						string.format(
							"Port %d is being used by another process `%s` (PID %d). Run `:lua vim.uv.kill(%d)` to kill it.",
							port,
							process.name,
							process.pid,
							process.pid
						),
						vim.log.levels.WARN
					)
				end
			end
		end
	end
	if M.serverObj then
		M.serverObj:stop()
	end
	M.serverObj = server.Server:new(config.config.dynamic_root and vim.fs.dirname(filepath) or nil)
	vim.wait(50, function()
		M.serverObj:start("127.0.0.1", port, function(client)
			if utils.supported_filetype(filepath) == "html" then
				server.websocket.send_json(client, { type = "reload" })
			else
				utils.async_read_file(filepath, function(_, data)
					local message = {
						type = "update",
						content = data,
					}
					server.websocket.send_json(client, message)
				end)
			end
		end)
		return true
	end, 98)
end

function M.pick()
	local pick_callback = function(pick_value)
		local filepath = pick_value
		M.start(filepath, config.config.port)
		vim.cmd.edit(filepath)
		utils.open_browser(
			string.format(
				"http://localhost:%d/%s",
				config.config.port,
				config.config.dynamic_root and vim.fs.basename(filepath) or filepath
			),
			config.config.browser
		)
	end

	local pickers = {
		["telescope"] = picker.telescope,
		["fzf-lua"] = picker.fzflua,
		["mini.pick"] = picker.minipick,
	}
	if config.config.picker then
		if not pickers[config.config.picker] then
			vim.notify("Error : picker opt invalid", vim.log.levels.ERROR)
			return
		end
		local status, err = pcall(pickers[config.config.picker], pick_callback)
		if not status then
			vim.notify("live-preview.nvim : error calling picker " .. config.config.picker, vim.log.levels.ERROR)
			vim.notify(err, vim.log.levels.ERROR)
		end
	else
		picker.pick(pick_callback)
	end
end

function M.help()
	local function print_help(text)
		print(text:format(config.config.cmd))
	end
	print("live-preview.nvim commands:")
	print_help([[  :%s start [filepath] - Start live preview. If no filepath is given, preview the current buffer.]])
	print_help([[  :%s close - Stop live preview]])
	print_help([[  :%s pick - Select a file to preview (using a picker like telescope.nvim, fzf-lua or mini.pick)]])
	print_help("  :%s help - Show this help")
end

--- Setup live preview
--- @param opts {commands: {start: string, stop: string}, port: number, browser: string, sync_scroll: boolean, telescope: {autoload: boolean}}|nil
function M.setup(opts)
	if config.config.cmd then
		vim.api.nvim_del_user_command(config.config.cmd)
	end

	local default_options = {
		cmd = "LivePreview",
		picker = nil,
		autokill = false,
		port = 5500,
		browser = "default",
		dynamic_root = false,
		sync_scroll = false,
	}

	config.set(vim.tbl_deep_extend("force", default_options, opts or {}))

	vim.api.nvim_create_user_command(config.config.cmd, function(cmd_opts)
		local subcommand = cmd_opts.fargs[1]
		if subcommand == "start" then
			local filepath
			if cmd_opts.fargs[2] ~= nil then
				filepath = cmd_opts.fargs[2]
				if not utils.is_absolute_path(filepath) then
					filepath = utils.joinpath(vim.uv.cwd(), filepath)
				end
			else
				filepath = vim.api.nvim_buf_get_name(0)
				if not utils.supported_filetype(filepath) then
					filepath = find_buf()
					if not filepath then
						print("live-preview.nvim only supports html, markdown, and asciidoc files")
						return
					end
				end
			end
			filepath = vim.fs.normalize(filepath):gsub(" ", "%%20")
			utils.open_browser(
				string.format(
					"http://localhost:%d/%s",
					config.config.port,
					config.config.dynamic_root and vim.fs.basename(filepath)
						or utils.get_relative_path(filepath, vim.fs.normalize(vim.uv.cwd() or ""))
				),
				config.config.browser
			)
			M.start(filepath, config.config.port)
		elseif subcommand == "close" then
			M.close()
			print("Live preview stopped")
		elseif subcommand == "pick" then
			M.pick()
		else
			M.help()
		end
	end, {
		nargs = "*",
		complete = function(ArgLead, CmdLine, CursorPos)
			local subcommands = { "start", "close", "pick", "help" }
			local subcommand = vim.split(CmdLine, " ")[2]
			if subcommand == "" then
				return subcommands
			elseif subcommand == ArgLead then
				local suggestions = {}
				for _, cmd in ipairs(subcommands) do
					if vim.startswith(cmd, ArgLead) then
						table.insert(suggestions, cmd)
					end
				end
				return suggestions
			else
				if subcommand == "start" then
					return vim.fn.getcompletion(ArgLead, "file")
				end
			end
		end,
	})
end

return M
