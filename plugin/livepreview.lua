local spec = require("livepreview.spec")
local nvim_ver_range = spec().engines.nvim
local nvim_ver_table = vim.version()
local nvim_ver = string.format("%d.%d.%d", nvim_ver_table.major, nvim_ver_table.minor, nvim_ver_table.patch)
local is_compatible = require("livepreview.health").is_compatible

if not is_compatible(nvim_ver, nvim_ver_range) then
	vim.notify_once("Live Preview requires Neovim " .. nvim_ver_range .. ", but you are using " .. nvim_ver)
end

package.loaded["live-preview"] = require("livepreview")
vim.filetype.add({
	pattern = {
		[".*/live%-preview%.nvim/doc/.+%.txt"] = "help",
		[".*/live%-preview%.nvim/*/template.lua"] = "luax"
	},
})
