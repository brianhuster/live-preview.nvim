local M = {}

---@enum Picker
M.pickers = {
	telescope = "telescope",
	fzflua = "fzf-lua",
	minipick = "mini.pick",
	snacks = "snacks.picker",
	vimui = "vim.ui.select",
	default = "",
}

---@class LivePreviewConfig
---@field picker Picker? picker to use to quickly open HTML/Markdown/Asciidoc/SVG files and run live-preview server
---@field port number? port to run the server on
---@field address string? address to bind the server to
---@field browser string? browser to open the preview in
---@field dynamic_root boolean? Whether to use the basename of the file as the root
---@field sync_scroll boolean? Whether to sync scroll the preview with the editor
---@field katex_macros table<string, string>? KaTeX macros passed to renderMathInElement as `macros`
M.default = {
	picker = "",
	address = "127.0.0.1",
	port = 5500,
	browser = "default",
	dynamic_root = false,
	sync_scroll = true,
	katex_macros = nil,
}

M.config = vim.deepcopy(M.default)

---@param name string
---@param value any
---@return boolean ok
---@return string? message
---@return vim.log.levels? level
---
---@diagnostic disable not right now
function M.validate(name, value) end

--- Configure live-preview.nvim
--- @param opts Config?
function M.set(opts)
	if not opts then
		return
	end
	M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
