local lp = require("livepreview")
lp.utils = require("livepreview.utils")
local fzf = require("fzf-lua")

local M = {}

function M.fzflua()
	local config = require("livepreview").config
	local files = lp.utils.list_supported_files(".")
	fzf.fzf_exec(files, {
		prompt = "Live Preview> ",
<<<<<<< HEAD
		previewer = vim.fn.executable("bat") == 1 and "bat" or "cat",
=======
		previewer = 'builtin',
>>>>>>> 6d9241b (fix)
		actions = {
			["default"] = function(selected)
				local filepath = selected[1]
				lp.live_start(filepath, lp.config.port)
				vim.cmd("edit " .. filepath)
				lp.utils.open_browser(
					string.format(
						"http://localhost:%d/%s",
						config.port,
						config.dynamic_root and vim.fs.dirname(filepath) or filepath
					),
					lp.config.browser
				)
			end,
		},
	})
end

function M.pick()
	if pcall(require, "telescope._extensions.livepreview") then
		require("telescope").extensions.livepreview.livepreview()
	elseif pcall(require, "fzf-lua") then
		M.fzflua()
	end
end

return M
