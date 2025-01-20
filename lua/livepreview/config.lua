local M = {}

---@enum Picker
M.pickers = {
	telescope = "telescope",
	fzflua = "fzf-lua",
	minipick = "mini.pick",
}

---@class Config
---@field picker Picker? picker to use to quickly open HTML/Markdown/Asciidoc/SVG files and run live-preview server
---@field autokill boolean? DEPRECATED
---@field port number? port to run the server on
---@field browser string? browser to open the preview in
---@field dynamic_root boolean? Whether to use the basename of the file as the root
---@field sync_scroll boolean? Whether to sync scroll the preview with the editor
M.default_config = {
	picker = "fzf-lua",
	autokill = false,
	port = 5500,
	browser = "default",
	dynamic_root = false,
	sync_scroll = true,
}

M.config = vim.deepcopy(M.default_config)

--- Configure live-preview.nvim
--- @param opts Config?
function M.set(opts)
	if not opts then
		return
	end
	if opts.picker then
		local ok = false
		for _, picker in pairs(M.pickers) do
			if picker == opts.picker then
				ok = true
				break
			end
		end
		if not ok then
			vim.notify("live-preview.nvim: Invalid 'picker' config option.", vim.log.levels.ERROR)
			opts.picker = nil
		end
	end
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
