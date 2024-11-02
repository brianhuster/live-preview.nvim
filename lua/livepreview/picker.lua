local lp = require("livepreview")
lp.utils = require("livepreview.utils")

local M = {}

local handle_pick = function(pick_value)
	local config = require("livepreview").config
	local filepath = pick_value
	lp.live_start(filepath, lp.config.port)
	vim.cmd("edit " .. filepath)
	lp.utils.open_browser(
		string.format(
			"http://localhost:%d/%s",
			lp.config.port,
			lp.config.dynamic_root and vim.fn.fnamemodify(filepath, ":t") or filepath),
		config.browser
	)
end

function M.telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local files = lp.utils.list_supported_files(".")
	pickers
		.new({}, {
			prompt_title = "Live Preview",
			finder = finders.new_table({
				results = files,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(_, _)
				actions.select_default:replace(function(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					local filepath = entry.value
					handle_pick(filepath)
				end)
				return true
			end,
		})
		:find()
end

function M.fzflua()
	local fzf = require("fzf-lua")
	local files = lp.utils.list_supported_files(".")
	fzf.fzf_exec(files, {
		prompt = "Live Preview> ",
		previewer = 'builtin',
		actions = {
			["default"] = function(selected)
				local filepath = selected[1]
				handle_pick(filepath)
			end,
		},
	})
end

function M.minipick()
	local MiniPick = require("mini.pick")
	local files = lp.utils.list_supported_files(".")

	local source = {
		items = files,
		name = 'Live Preview',
		preview = MiniPick.default_preview,
		choose = function(item)
			handle_pick(item)
		end,
	}

	MiniPick.start({
		source = source,
	})
end

function M.pick()
	if pcall(require, "telescope._extensions.livepreview") then
		require("telescope").extensions.livepreview.livepreview()
	elseif pcall(require, "fzf-lua") then
		M.fzflua()
	elseif pcall(require, "mini.pick") then
		M.minipick()
	else
		vim.api.nvim_err_writeln("No picker found. Please install telescope.nvim, fzf-lua or mini.pick")
	end
end

return M
