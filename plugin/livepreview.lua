if vim.g.loaded_livepreview then
	return
end

vim.g.loaded_livepreview = true
local PORT_PREFIX = "++port="

local health = require("livepreview.health")
local cmd = "LivePreview"
local api = vim.api

if not health.is_nvim_compatible() then
	vim.notify_once(
		("live-preview.nvim requires Nvim %s, but you are using Nvim %s"):format(
			health.supported_nvim_ver_range,
			health.nvim_ver
		),
		vim.log.levels.ERROR
	)
	return
end

api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		require("livepreview").close()
	end,
})

api.nvim_create_user_command(cmd, function(cmd_opts)
	local utils = require("livepreview.utils")
	local lp = require("livepreview")
	local Config = require("livepreview.config").config
	local fs = vim.fs

	local subcommand = cmd_opts.fargs[1]

	if subcommand == "start" then
		local filepath
		local port = Config.port

		-- determines if the options given is a port or filepath
		for i = 2, 3 do
			local arg = cmd_opts.fargs[i]
			if arg then
				if arg:sub(1, #PORT_PREFIX) == PORT_PREFIX then
					-- If the substring is not a number, this returns nil
					local numb = tonumber(arg:sub(#PORT_PREFIX + 1))
					if numb then
						port = numb
					else
						vim.notify(
							"Error: LivePreview couldnt parse ++port option. Invalid Number.",
							vim.log.levels.WARN
						)
					end
				else
					filepath = arg
				end
			end
		end

		if filepath ~= nil then
			filepath = cmd_opts.fargs[2]
			if not utils.is_absolute_path(filepath) then
				filepath = fs.joinpath(vim.uv.cwd(), filepath)
			end
		else
			filepath = api.nvim_buf_get_name(0)
			if not utils.supported_filetype(filepath) then
				filepath = utils.find_supported_buf()
				if not filepath then
					vim.notify(
						"live-preview.nvim only supports markdown, asciidoc, svg and html files",
						vim.log.levels.ERROR
					)
					return
				end
			end
		end
		filepath = fs.normalize(filepath)
		if not lp.start(filepath, port) then
			return
		end

		local urlpath = (Config.dynamic_root and fs.basename(filepath) or utils.get_relative_path(
			filepath,
			fs.normalize(vim.uv.cwd() or "")
		)):gsub(" ", "%%20")
		local url = ("http://localhost:%d/%s"):format(Config.port, urlpath)
		print("live-preview.nvim: Opening browser at " .. url)
		utils.open_browser(url, Config.browser)
	elseif subcommand == "close" then
		lp.close()
		print("Live preview stopped")
	elseif subcommand == "pick" then
		-- Create port option, with the default port, then if arguments were
		-- given it checks that it is a valid number and then changes the port
		-- option to the given argument
		local port = Config.port
		-- Must set opt to "" as default else the sub statement returns an error
		local opt = cmd_opts.fargs[2] or ""
		if opt:sub(1, #PORT_PREFIX) == PORT_PREFIX then
			-- If the substring is not a number, this returns nil
			local numb = tonumber(opt:sub(#PORT_PREFIX + 1))
			if numb then
				port = numb
			else
				vim.notify("Error: LivePreview couldnt parse ++port option. Invalid Number.", vim.log.levels.WARN)
			end
		else
			vim.notify(
				"Error: LivePreview couldnt parse parameter. Parameters should start be [++port=number].",
				vim.log.levels.WARN
			)
		end
		lp.pick(port)
	else
		lp.help()
	end
end, {
	nargs = "*",
	complete = function(ArgLead, CmdLine, CursorPos)
		local subcommands = { "start", "close", "pick", "-h", "--help" }
		local subcommand = vim.split(CmdLine, " ")[2]
		if subcommand == "" then
			return subcommands
		elseif subcommand == ArgLead then
			return vim.tbl_filter(function(subcmd)
				return vim.startswith(subcmd, ArgLead)
			end, subcommands)
		else
			if subcommand == "start" then
				return vim.fn.getcompletion(ArgLead, "file")
			end
		end
	end,
})

local config = require("livepreview.config")
--- Public API
LivePreview = {
	config = vim.deepcopy(config.default),
}

setmetatable(LivePreview.config, {
	__index = function(_, key)
		if config.default[key] == nil then
			vim.notify(("Error: live-preview.nvim has no config option '%s'"):format(key), vim.log.levels.ERROR)
			return
		end
		return config.config[key]
	end,
	__newindex = function(_, key, value)
		if config.default[key] == nil then
			vim.notify(("Error: live-preview.nvim has no config option '%s'"):format(key), vim.log.levels.ERROR)
			return
		end
		config.set({ [key] = value })
	end,
})
