local M = {}

local cmd = "LivePreview"
local server = require("livepreview.server")
local utils = require("livepreview.utils")
local config = require("livepreview.config")

---@type LivePreviewServer?
M.serverObj = nil

--- Stop live-preview server
function M.close()
	if M.serverObj then
		M.serverObj:stop(function()
			print("live-preview.nvim: Server closed")
		end)
		M.serverObj = nil
	end
end

--- Check if there is a live-preview server process
--- Note: this does not check if the server is running healthy
--- @return boolean
function M.is_running()
	return not not (M.serverObj and M.serverObj.server)
end

--- Start live-preview server
---@param filepath string: path to the file
---@param port number: port to run the server on
---@return boolean?
function M.start(filepath, port)
	local processes = utils.processes_listening_on_port(port)
	if #processes > 0 then
		for _, process in ipairs(processes) do
			if process.pid ~= vim.uv.os_getpid() then
				-- local kill_confirm = vim.fn.confirm(
				-- 	("Port %d is being listened by another process `%s` (PID %d). Kill it?"):format(port, process.name, process.pid),
				-- 	"&Yes\n&No", 2)
				-- if kill_confirm ~= 1 then return else utils.kill(process.pid) end
				vim.notify(
					("Port %d is being used by another process `%s` (PID %d). Run `:lua vim.uv.kill(%d)` to kill it or change the port with `:lua LivePreview.config.port = <new_port>`"):format(
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
	M.close()

	M.serverObj = server.Server:new(config.config.dynamic_root and vim.fs.dirname(filepath) or nil)
	vim.wait(50, function()
		local function onTextChanged(client)
			local bufname = vim.api.nvim_buf_get_name(0)
			if not utils.supported_filetype(bufname) or utils.supported_filetype(bufname) == "html" then
				return
			end
			local message = {
				filepath = bufname,
				type = "update",
				content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"),
			}
			server.websocket.send_json(client, message)
		end

		M.serverObj:start("127.0.0.1", port, {
			on_events = utils.supported_filetype(filepath) == "html"
					and {
						---@param client uv_tcp_t
						---@param data {filename: string, event: FsEvent}
						LivePreviewDirChanged = function(client, data)
							if not vim.regex([[\.\(html\|css\|js\)$]]):match_str(data.filename) then
								return
							end

							server.websocket.send_json(client, { type = "reload" })
						end,
					}
				or {
					TextChanged = vim.schedule_wrap(onTextChanged),
					TextChangedI = vim.schedule_wrap(onTextChanged),
				},
		})

		return true
	end, 98)

	return true
end

--- Create picker object and open the picker
---@param port number [Port number to open on, this is optional]
function M.pick(port)
	-- Adding port fallback if the parameter is nil
	port = port or config.config.port
	local picker = require("livepreview.picker")

	local pick_callback = function(pick_value)
		local filepath = pick_value or nil
		if not filepath then
			vim.notify("No file picked", vim.log.levels.INFO)
			return
		end
		M.start(filepath, port)
		vim.cmd.edit(filepath)
		utils.open_browser(
			string.format(
				"http://localhost:%d/%s",
				port,
				config.config.dynamic_root and vim.fs.basename(filepath) or filepath
			),
			config.config.browser
		)
	end

	local picker_funcs = {}
	for k, v in pairs(config.pickers) do
		picker_funcs[v] = picker[k]
	end

	if config.config.picker and #config.config.picker > 0 then
		if not picker_funcs[config.config.picker] then
			vim.notify("live-preview.nvim: config option 'picker' invalid", vim.log.levels.ERROR)
			return
		end
		local status, err = pcall(picker_funcs[config.config.picker], pick_callback)
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
		print(text:format(cmd))
	end
	print("live-preview.nvim commands:")
	print_help(
		[[  :%s start [filepath] - Start live-preview server and open browser. If no filepath is given, preview the current buffer.]]
	)
	print_help([[  :%s close - Stop live-preview server]])
	print_help([[  :%s pick - Select a file to preview (using a picker like telescope.nvim, fzf-lua or mini.pick)]])
	print("  :che[ckhealth] livepreview - Check the health of the plugin")
	print("  :h[elp] livepreview - Open the documentation")
end

--- @deprecated Use `require('livepreview.config').set(opts)` instead
function M.setup(opts)
	config.set(opts)
end

return M
