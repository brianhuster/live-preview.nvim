---@brief ETag module
--- To require this module, do
--- ```lua
--- local etag = require('live-preview.server.utils.etag')
--- ```

local M = {}

--- Generate an ETag for a file
--- The Etag is generated based on the modification time of the file
--- @param file_path string: path to the file
--- @return string | nil: ETag
function M.generate(file_path)
	local attr = vim.uv.fs_stat(file_path)
	if not attr then
		return nil
	end
	local modification_time = attr.mtime
	return modification_time.sec .. "." .. modification_time.nsec
end

return M
