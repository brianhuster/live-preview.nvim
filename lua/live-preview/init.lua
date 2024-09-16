local M = {}

local default_options = {
    commands = {
        start = "LivePreview",
        stop = "StopPreview",
    },
    port = 5500,
}

local function get_path_lua_file()
    local info = debug.getinfo(2, "S")
    if not info then
        print("Cannot get info")
        return nil
    end
    local source = info.source
    if source:sub(1, 1) == "@" then
        return source:sub(2)
    end
end

local function get_parent_path(full_path, subpath)
    local escaped_subpath = subpath:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    local pattern = "(.*)" .. escaped_subpath
    local parent_path = full_path:match(pattern)
    return parent_path
end

local function get_plugin_path()
    local full_path = get_path_lua_file()
    if not full_path then
        return nil
    end
    local subpath = "/lua/live-preview/init.lua"
    return get_parent_path(full_path, subpath)
end

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

local function open_browser(port)
    vim.ui.open(
        string.format(
            "http://localhost:%d",
            port
        )
    )
end

-- Kill any process using the port
function M.stop_preview(port)
    local kill_command = string.format(
        "lsof -t -i:%d | xargs -r kill -9",
        port
    )
    if vim.fn.has("win32") == 1 then
        kill_command = string.format(
            "netstat -ano | findstr :%d | findstr LISTENING | for /F \"tokens=5\" %%i in ('more') do taskkill /F /PID %%i",
            port
        )
    end
    os.execute(kill_command)
end

function M.preview_file(port)
    local filename = vim.fn.expand('%:p')
    local target_dir = vim.fn.expand('%:p:h')
    if not filename or filename == "" then
        filename = find_buf()
        if not filename then
            print("Cannot find a file")
            return
        end
    end

    local extname = vim.fn.fnamemodify(filename, ":e")
    local supported_exts = { "md", "html" }

    if not vim.tbl_contains(supported_exts, extname) then
        filename = find_buf()
        if not filename then
            print("Unsupported file type")
            return
        end
    end

    M.stop_preview(port)
    local plugin_path = get_plugin_path()
    local log_file = plugin_path .. '/logs/log.txt'
    local command = string.format("cd %s && nodemon --watch %s %s %d", plugin_path, target_dir, filename, port)

    vim.fn.jobstart(command, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    print("stdout: " .. line)
                    local file = io.open(log_file, "a")
                    if file then
                        file:write("stdout: " .. line .. "\n")
                        file:close()
                    else
                        print("Cannot find log file")
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    print("stderr: " .. line)
                    local file = io.open(log_file, "a")
                    if file then
                        file:write("stderr: " .. line .. "\n")
                        file:close()
                    end
                end
            end
        end,
        on_exit = function(_, code)
            if code ~= 0 then
                print("Error starting the server")
            end
        end,

    })
    open_browser(port)
end

function M.touch_file()
    local filepath = vim.fn.expand('%:p')
    if vim.fn.filereadable(filepath) == 1 then
        vim.fn.system('touch ' .. filepath)
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

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*",
        callback = function()
            require("live-preview").touch_file()
        end,
    })

    disable_atomic_writes()
end

return M
