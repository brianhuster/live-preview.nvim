---@brief
--- Returns the metadata of live-preview.nvim as a table.
local function spec()
    local read_file = require("live-preview.utils").uv_read_file
    local get_plugin_path = require("live-preview.utils").get_plugin_path

    local path_to_packspe = vim.fs.joinpath(get_plugin_path(), "pkg.json")
    local body = read_file(path_to_packspe)
    if not body then
        return nil
    end
    return vim.json.decode(body)
end

return spec
