local health = require("livepreview.health")
local cmd = 'LivePreview'
local api = vim.api

if not health.is_nvim_compatible() then
	vim.notify_once(
		string.format(
			[["live-preview.nvim requires Nvim %s, but you are using Nvim %s"]],
			health.supported_nvim_ver_range,
			health.nvim_ver
		),
		vim.log.levels.ERROR
	)
end

vim.filetype.add({
	pattern = {
		[".*/live%-preview%.nvim/doc/.+%.txt"] = "help",
		[".*/live%-preview%.nvim/.*template.lua"] = "luatemplate",
	},
})

api.nvim_create_autocmd("VimLeavePre", {
	callback = require("livepreview").close
})

api.nvim_create_user_command(cmd, function(cmd_opts)
	local utils = require("livepreview.utils")
	local lp = require("livepreview")
	local config = require("livepreview.config")

	local subcommand = cmd_opts.fargs[1]

	if subcommand == "start" then
		local filepath
		if cmd_opts.fargs[2] ~= nil then
			filepath = cmd_opts.fargs[2]
			if not utils.is_absolute_path(filepath) then
				filepath = utils.joinpath(vim.uv.cwd(), filepath)
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
		lp.start(filepath, config.config.port)
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
		local subcommands = { "start", "close", "pick", "help" }
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
