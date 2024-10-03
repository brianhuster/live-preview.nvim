local spec = require("live-preview.spec")
local nvim_ver_range = spec().engines.nvim
local nvim_ver_table = vim.version()
local nvim_ver = string.format("%d.%d.%d", nvim_ver_table.major, nvim_ver_table.minor, nvim_ver_table.patch)
local is_compatible = require("live-preview.health").is_compatible

if not is_compatible(nvim_ver, nvim_ver_range) then
	vim.notify_once("Live Preview requires Neovim " .. nvim_ver_range .. ", but you are using " .. nvim_ver)
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*/live-preview.nvim/doc/*.txt",
	callback = function()
		vim.bo.filetype = 'help'
		vim.bo.readonly = true
	end,
})
