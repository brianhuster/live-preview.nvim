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
            if buf_name:match("%.md$") or buf_name:match("%.html$") then
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
    local extname = vim.fn.fnamemodify(filepath, ":e")
    local supported_exts = { "md", "html" }

    if not vim.tbl_contains(supported_exts, extname) then
        filepath = find_buf()
        if not filepath or filepath == "" then
            print("Live preview only supports markdown and html files")
            return
        end
    end

    server.start("127.0.0.1", port, {
        webroot = vim.fs.dirname(filepath),
    })
    print(filepath)
end

local function disable_atomic_writes()
    vim.o.backupcopy = 'yes'
end

function M.setup()
    local opts = vim.tbl_deep_extend("force", default_options, opts or {})

    vim.api.nvim_create_user_command(opts.commands.start, function()
        local filepath = vim.fn.expand('%:p')
        if not filepath:match("%.md$") and not filepath:match("%.html$") then
            filepath = find_buf()
            if not filepath then
                print("Cannot find a markdown/html file to preview")
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
