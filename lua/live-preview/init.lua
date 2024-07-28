local M = {}

local default_options = {
    commands = {
        start = "LivePreview",
        stop = "StopPreview",
    },
    port = 3000,
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

function M.open_browser(port)
    local open_browser_command = "xdg-open"
    if vim.fn.has("mac") == 1 then
        open_browser_command = "open"
    elseif vim.fn.has("win32") == 1 then
        open_browser_command = "start"
    end
    os.execute(string.format(
        "%s http://localhost:%d", 
        open_browser_command, 
        port
    ))
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
        print("Unsupported file type")
        return
    end

    M.stop_preview(port)

    local log_file = vim.fn.stdpath('data') .. '/lazy/live-preview.nvim/logs/log.txt'
    local command = string.format("cd ~/.local/share/nvim/lazy/live-preview.nvim && nodemon --watch %s %s %d", target_dir, filename, port)

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

    M.open_browser(port)
end

function M.touch_file()
  local filepath = vim.fn.expand('%:p')
  if vim.fn.filereadable(filepath) == 1 then
    vim.fn.system('touch ' .. filepath)
  end
end

-- Function to disable atomic writes
function M.disable_atomic_writes()
  vim.opt.backupcopy = 'yes'
end

function M.setup()
    opts = vim.tbl_deep_extend("force", default_options, opts or {})

    vim.api.nvim_create_user_command(opts.commands.start, function()
        M.preview_file(opts.port)
        print("Live preview started")
    end, {})

    vim.api.nvim_create_user_command(opts.commands.stop, function()
        M.stop_preview(opts.port)
        print("Live preview stopped")
    end, {})

    vim.cmd('autocmd BufWritePost * lua require("live-preview").touch_file()')
    M.disable_atomic_writes()
end

return M
