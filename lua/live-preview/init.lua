local utils = require("live-preview.utils")
local server = require("live-preview.server")

local M = {}

local default_options = {
    commands = {
        start = "LivePreview",
        stop = "StopPreview",
    },
    port = 5500,
    browser = "default",
}


local function find_buf() -- find html/md buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if utils.supported_filetype(buf_name) then
                return buf_name
            end
        end
    end
    return nil
end


function M.stop_preview()
    server.stop()
end

function M.preview_file(filepath, port)
    server.start("127.0.0.1", port, {
        webroot = vim.fs.dirname(filepath),
    })
end

local function disable_atomic_writes()
    vim.o.backupcopy = 'yes'
end

function M.setup()
    local opts = vim.tbl_deep_extend("force", default_options, opts or {})

    vim.api.nvim_create_user_command(opts.commands.start, function()
        local filepath = vim.fn.expand('%:p')
        if not utils.supported_filetype(filepath) then
            filepath = find_buf()
            if not filepath then
                print("live-preview.nvim only supports html, markdown, and asciidoc files")
                return
            end
        end
        utils.open_browser(
            string.format(
                "http://localhost:%d/%s",
                opts.port,
                vim.fs.basename(filepath)
            ),
            opts.browser
        )

        M.preview_file(filepath, opts.port)
    end, {})

    vim.api.nvim_create_user_command(opts.commands.stop, function()
        M.stop_preview()
        print("Live preview stopped")
    end, {})

    disable_atomic_writes()
end

return M
