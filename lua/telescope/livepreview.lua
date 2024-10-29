local M = {}

local livepreview = require("livepreview")
livepreview.utils = require("livepreview.utils")
local telescope = require("telescope")
local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

M.setup = function(opts)
	livepreview.setup(opts)
	telescope.setup({
		defaults = {
			mappings = {
				i = {
					["<CR>"] = function(prompt_bufnr)
						local entry = require("telescope.actions.state").get_selected_entry()
						actions.close(prompt_bufnr)
						local filepath = entry.path
						if livepreview.utils.supported_filetype(filepath) then
							livepreview.preview_file(filepath, livepreview.config.port)
						else
							print("Selected file is not supported for live preview")
						end
					end,
				},
			},
		},
	})
	telescope.register_extension({
		exports = {
			livepreview_start = function()
				pickers
					.new({}, {
						prompt_title = "Live Preview",
						finder = finders.new_oneshot_job({ "find", ".", "-type", "f" }, {}),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(_, map)
							map("i", "<CR>", function(prompt_bufnr)
								local entry = require("telescope.actions.state").get_selected_entry()
								actions.close(prompt_bufnr)
								local filepath = entry.value
								if livepreview.utils.supported_filetype(filepath) then
									livepreview.preview_file(filepath, livepreview.config.port)
								else
									print("Selected file is not supported for live preview")
								end
							end)
							return true
						end,
					})
					:find()
			end,
		},
	})

	-- Picker for LivePreviewStop
	telescope.register_extension({
		exports = {
			livepreview_stop = function()
				livepreview.stop()
			end,
		},
	})
end

return M
