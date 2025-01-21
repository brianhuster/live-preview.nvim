if vim.g.loaded_livepreview then
	return
end

vim.g.loaded_livepreview = true

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
		if cmd_opts.fargs[2] ~= nil then
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
		lp.start(filepath, Config.port)
		local urlpath = (Config.dynamic_root and fs.basename(filepath) or utils.get_relative_path(
			filepath,
			fs.normalize(vim.uv.cwd() or "")
		)):gsub(" ", "%%20")
		utils.open_browser(("http://localhost:%d/%s"):format(Config.port, urlpath), Config.browser)
	elseif subcommand == "close" then
		lp.close()
		print("Live preview stopped")
	elseif subcommand == "pick" then
		lp.pick()
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


--- Public API
LivePreview = {
	config = {}
}

for k, _ in pairs(require 'livepreview.config'.default) do
	LivePreview.config[k] = nil
end

setmetatable(LivePreview.config, {
	__index = function(_, key)
		if vim.fn.has_key(require 'livepreview.config'.default, key) == 0 then
			vim.notify(("Error: live-preview.nvim has no config option '%s'"):format(key), vim.log.levels.ERROR)
			return
		end
		return require("livepreview.config").config[key]
	end,
	__newindex = function(_, key, value)
		if vim.fn.has_key(require 'livepreview.config'.default, key) == 0 then
			vim.notify(("Error: live-preview.nvim has no config option '%s'"):format(key), vim.log.levels.ERROR)
			return
		end
		require("livepreview.config").set({ [key] = value })
	end,
})
