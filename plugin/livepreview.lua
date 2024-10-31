local health = require("livepreview.health")

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

package.loaded["live-preview"] = require("livepreview")

vim.filetype.add({
	pattern = {
		[".*/live%-preview%.nvim/doc/.+%.txt"] = "help",
		[".*/live%-preview%.nvim/.*template.lua"] = "luatemplate",
	},
})

require("livepreview").setup()

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		require("livepreview").live_stop()
	end,
})
