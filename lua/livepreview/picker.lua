---@brief Picker module for live-preview.nvim
--- To use this module, require it in your Lua code:
--- ```lua
--- local picker = require('livepreview.picker')
--- ```

local utils = require("livepreview.utils")

local M = {}

---@brief Open a telescope.nvim picker to select a file
---@param callback function: Callback function to run after selecting a file
function M.telescope(callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local files = utils.list_supported_files(".") or { "" }
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

---@brief Open a fzf-lua picker to select a file
---@param callback function: Callback function to run after selecting a file
function M.fzflua(callback)
	local fzf = require("fzf-lua")
	local files = utils.list_supported_files(".") or { "" }
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

---@brief Open a mini.pick picker to select a file
---@param callback function: Callback function to run after selecting a file
function M.minipick(callback)
	local MiniPick = require("mini.pick")
	local files = utils.list_supported_files(".") or { "" }

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

---@brief Open a fallback picker to select a file, can indicate the picker
---@param picker function: A picker function like vim.ui.select
---@param callback function: Callback function to run after selecting a file
function M.vimui(callback, picker)
	picker = picker or vim.ui.select
	local files = utils.list_supported_files(".") or { "" }

	local source = {
		items = files,
		preview = {
			prompt = "Live Preview",
			format_item = function(item)
				return item
			end,
		},
		choose = function(item)
			callback(item)
		end,
	}

	-- Call the picker function with correct argument order
	picker(source.items, source.preview, source.choose)
end

---@brief Open a picker to select a file.
---
---This function will try to use telescope.nvim, fzf-lua, or mini.pick to open a picker to select a file.
---@param callback function: Callback function to run after selecting a file
function M.pick(callback)
	if pcall(require, "telescope") then
		M.telescope(callback)
	elseif pcall(require, "fzf-lua") then
		M.fzflua(callback)
	elseif pcall(require, "mini.pick") then
		M.minipick(callback)
	elseif pcall(require, "snacks.picker") then
		M.vimui(callback, require("snacks.picker").select)
	else
		-- fallback to vim.ui.select
		M.vimui(callback, vim.ui.select)
		vim.notify(
			"No picker found. Defaulting to vim.ui.select. Please install telescope.nvim, fzf-lua, mini.pick, or snacks.nvim.",
			vim.log.levels.WARN
		)
	end
end

return M
