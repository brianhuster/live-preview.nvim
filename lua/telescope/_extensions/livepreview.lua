local uv = vim.uv
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local lp = require("livepreview")
lp.utils = require("livepreview.utils")

local M = {}

--- Find supported files in a directory and its subdirectories
--- @param directory string
--- @return table: a table with the paths of the supported files
local function list_supported_files(directory)
	local files = {}
	local function scan_dir(dir)
		local handle = uv.fs_scandir(dir)
		if not handle then
			return
		end
		while true do
			local name, type = uv.fs_scandir_next(handle)
			if not name then
				break
			end
			local filepath = dir .. "/" .. name
			if type == "directory" then
				scan_dir(filepath)
			else
				if lp.utils.supported_filetype(filepath) then
					table.insert(files, filepath)
				end
			end
		end
	end
	scan_dir(directory)
	return files
end

function M.livepreview()
	local files = list_supported_files(".")
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
					lp.live_start(filepath, lp.config.port)
					vim.cmd("edit " .. filepath)
					lp.utils.open_browser(
						string.format("http://localhost:%d/%s", lp.config.port, filepath),
						lp.config.browser
					)
				end)
				return true
			end,
		})
		:find()
end

return require("telescope").register_extension({
	setup = function() end,
	exports = M,
})
