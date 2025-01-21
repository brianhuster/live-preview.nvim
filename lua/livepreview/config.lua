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
M.default = {
	picker = nil,
	autokill = false,
	port = 5500,
	browser = "default",
	dynamic_root = false,
	sync_scroll = true,
}

M.config = vim.deepcopy(M.default)

---@param name string
---@param value any
---@return boolean ok
---@return string? message
---@return vim.log.levels? level
function M.validate(name, value)
end

--- Configure live-preview.nvim
--- @param opts Config?
function M.set(opts)
	if not opts then
		return
	end
	M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
