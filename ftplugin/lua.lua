if vim.api.nvim_buf_get_name(0):match(".*/live%-preview%.nvim/.*template.lua") then
	vim.bo.filetype = "luatemplate"
end