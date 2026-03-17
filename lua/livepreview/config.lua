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

---@class LivePreviewMermaidConfig
---@field renderer "default"|"beautiful" Renderer to use for mermaid diagrams (default: "default")
---@field theme string beautiful-mermaid theme name (only used when renderer = "beautiful")

---@class LivePreviewConfig
---@field picker Picker? picker to use to quickly open HTML/Markdown/Asciidoc/SVG files and run live-preview server
---@field port number? port to run the server on
---@field address string? address to bind the server to
---@field browser string? browser to open the preview in
---@field dynamic_root boolean? Whether to use the basename of the file as the root
---@field sync_scroll boolean? Whether to sync scroll the preview with the editor
---@field mermaid LivePreviewMermaidConfig? Mermaid rendering options
M.default = {
	picker = "",
	address = "127.0.0.1",
	port = 5500,
	browser = "default",
	dynamic_root = false,
	sync_scroll = true,
	mermaid = {
		renderer = "default",
		theme = "github-light",
	},
}

M.config = vim.deepcopy(M.default)

---@param name string
---@param value any
---@return boolean ok
---@return string? message
---@return vim.log.levels? level
function M.validate(name, value)
	if name == "mermaid" then
		if value.renderer and value.renderer ~= "default" and value.renderer ~= "beautiful" then
			return false, "mermaid.renderer must be 'default' or 'beautiful'", vim.log.levels.ERROR
		end
	end
	return true
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
