local livepreview = require("livepreview")
local telescope = require("telescope")
local actions = require("telescope.actions")

local M = {}

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
	vim.keymap.set("n", opts.keymap and opts.keymap.start or "<leader>lp", function()
		require("telescope.builtin").find_files({
			prompt_title = "Live Preview",
			cwd = vim.fn.getcwd(),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local entry = require("telescope.actions.state").get_selected_entry()
					actions.close(prompt_bufnr)
					local filepath = entry.path
					if livepreview.utils.supported_filetype(filepath) then
						livepreview.preview_file(filepath, livepreview.config.port)
					else
						print("Selected file is not supported for live preview")
					end
				end)
				return true
			end,
		})
	end, { noremap = true, silent = true })
end

return M
