---@brief ETag module
--- To require this module, do
--- ```lua
--- local etag = require('livepreview.server.utils.etag')
--- ```

local M = {}

local plugin_path = require("livepreview.utils").get_plugin_path()
local template_path = vim.fs.joinpath(plugin_path, "lua/livepreview/template.lua")

--- Generate an ETag for a file
--- The ETag is built from the identity, size and modification time of the file, and the
--- modification time of the template the file is rendered with. Files of different folders
--- served at the same URL in turn must not share an ETag, or the browser keeps the page of
--- the previous folder.
--- @param file_path string: path to the file
--- @param variant string|nil: (optional) representation of the file, e.g. "html" for the page rendered from it
--- @return string?: ETag
function M.generate(file_path, variant)
	local attr = vim.uv.fs_stat(file_path)
	if not attr then
		return nil
	end
	local template_stat = vim.uv.fs_stat(template_path)
	local template_mtime = template_stat and template_stat.mtime or { sec = 0, nsec = 0 }
	return ('"%d-%d-%d-%d.%d-%d.%d%s"'):format(
		attr.dev,
		attr.ino,
		attr.size,
		attr.mtime.sec,
		attr.mtime.nsec,
		template_mtime.sec,
		template_mtime.nsec,
		variant and "-" .. variant or ""
	)
end

return M
