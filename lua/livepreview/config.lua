local M = {}

M.config = {
	picker = nil,
	autokill = false,
	port = 5500,
	browser = "default",
	dynamic_root = false,
	sync_scroll = false,
}

function M.set(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
