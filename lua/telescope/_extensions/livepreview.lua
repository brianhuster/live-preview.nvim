local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local lp = require("livepreview")
lp.utils = require("livepreview.utils")

local function open()
	local handle = lp.utils.await_term_cmd("find . -type f")
	local result = handle.stdout

	local files = {}
	for file in result:gmatch("[^\r\n]+") do
		if lp.utils.supported_filetype(file) then
			table.insert(files, file)
		end
	end

	pickers
		.new({}, {
			prompt_title = "Live Preview",
			finder = finders.new_table({
				results = files,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(_, map)
				actions.select_default:replace(function(prompt_bufnr)
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					local filepath = entry.value
					if lp.utils.supported_filetype(filepath) then
						lp.preview_file(filepath, lp.config.port)
						vim.cmd("edit " .. filepath)
						lp.utils.open_browser(
							string.format("http://localhost:%d/%s", lp.config.port, filepath),
							lp.config.browser
						)
					else
						print("Selected file is not supported for live-preview.nvim")
					end
				end)
				return true
			end,
		})
		:find()
end

return require("telescope").register_extension({
	setup = function() end,
	exports = {
		livepreview = open,
	}
})
