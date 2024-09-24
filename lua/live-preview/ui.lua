-- Example of creating a floating window
local M = {}

function M.create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true) -- create a new buffer
    local width = 60
    local height = 20
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    return buf, win
end


return M
