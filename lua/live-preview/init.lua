local utils = require("live-preview.utils")
local server = require("live-preview.server")

local M = {}

local default_options = {
    commands = {
        start = "LivePreview",
        stop = "StopPreview",
    },
    port = 5500,
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


-- Kill any process using the port
function M.stop_preview(port)
    local kill_command = string.format(
        "lsof -t -i:%d | xargs -r kill -9",
        port
    )

    if vim.uv.os_uname().version:match("Windows") then
        kill_command = string.format(
            "netstat -ano | findstr :%d | findstr LISTENING | for /F \"tokens=5\" %%i in ('more') do taskkill /F /PID %%i",
            port
        )
    end
    os.execute(kill_command)
end

function M.preview_file(port)
    local filepath = vim.fn.expand('%:p')
    if not filepath or filepath == "" then
        filepath = find_buf()
        if not filepath then
            print("Cannot find a file")
            return
        end
    end

    local extname = vim.fn.fnamemodify(filepath, ":e")
    local supported_exts = { "md", "html" }

    if not vim.tbl_contains(supported_exts, extname) then
        filepath = find_buf()
        if not filepath or filepath == "" then
            print("Unsupported file type")
            return
        end
    end


    -- M.stop_preview(port)
    if extname == "md" then
        local md_content = utils.uv_read_file(filepath)
        server.start("127.0.0.1", port, {
            webroot = vim.fs.dirname(filepath),
            html_content = md_content
        })
        utils.open_browser(string.format("http://localhost:%d", port))
    else
        server.start("127.0.0.1", port, {
            webroot = vim.fs.dirname(filepath),
        })
        utils.open_browser(string.format("http://localhost:%d/%s", port, vim.fs.basename(filepath)))
    end
end

-- Function to disable atomic writes
local function disable_atomic_writes()
    vim.opt.backupcopy = 'yes'
end

function M.setup()
    local opts = vim.tbl_deep_extend("force", default_options, opts or {})

    vim.api.nvim_create_user_command(opts.commands.start, function()
        M.preview_file(opts.port)
        print("Live preview started")
    end, {})

    vim.api.nvim_create_user_command(opts.commands.stop, function()
        M.stop_preview(opts.port)
        print("Live preview stopped")
    end, {})

    disable_atomic_writes()
end

return M
