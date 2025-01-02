if vim.api.nvim_buf_get_name(0):match(".*/live%-preview%.nvim/doc/.+%.txt") then
	vim.bo.filetype = "help"
end
