local utils = require("livepreview.utils")

local M = {}

function M.telescope(callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local files = utils.list_supported_files(".")
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
					callback(filepath)
				end)
				return true
			end,
		})
		:find()
end

function M.fzflua(callback)
	local fzf = require("fzf-lua")
	local files = utils.list_supported_files(".")
	fzf.fzf_exec(files, {
		prompt = "Live Preview> ",
		previewer = "builtin",
		actions = {
			["default"] = function(selected)
				local filepath = selected[1]
				callback(filepath)
			end,
		},
	})
end

function M.minipick(callback)
	local MiniPick = require("mini.pick")
	local files = utils.list_supported_files(".")

	local source = {
		items = files,
		name = "Live Preview",
		preview = MiniPick.default_preview,
		choose = function(item)
			callback(item)
		end,
	}

	MiniPick.start({
		source = source,
	})
end

function M.pick(callback)
	if pcall(require, "telescope._extensions.livepreview") then
		M.telescope(callback)
	elseif pcall(require, "fzf-lua") then
		M.fzflua(callback)
	elseif pcall(require, "mini.pick") then
		M.minipick(callback)
	else
		vim.api.nvim_err_writeln("No picker found. Please install telescope.nvim, fzf-lua or mini.pick")
	end
end

return M
