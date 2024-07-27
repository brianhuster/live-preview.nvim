local M = {}

-- Function to stop any process using port 3000
function M.stop_preview()
    local port = 3000
    if vim.fn.has("win32") == 1 then
        local kill_command = string.format(
            "netstat -ano | findstr :%d | findstr LISTENING | for /F \"tokens=5\" %%i in ('more') do taskkill /F /PID %%i",
            port
        )
        os.execute(kill_command)
    else
        local kill_command = string.format(
            "lsof -t -i:%d | xargs -r kill -9",
            port
        )
        os.execute(kill_command)
    end
end

-- Function to preview the file
function M.preview_file()
    local filename = vim.fn.expand('%:p')
    local target_dir = vim.fn.expand('%:p:h')
    if not filename or filename == "" then
        print("No file is open")
        return
    end

    local extname = vim.fn.fnamemodify(filename, ":e")
    local supported_exts = { "md", "html" }

    if not vim.tbl_contains(supported_exts, extname) then
        print("Unsupported file type")
        return
    end

    -- Start nodemon server
    M.stop_preview()

    local log_file = vim.fn.stdpath('data') .. '/lazy/live-preview.nvim/log.txt'
    local command = string.format("nodemon --watch %s --exec 'node ~/.local/share/nvim/lazy/live-preview.nvim/server.js %s'", target_dir, filename)

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

    -- Choose the appropriate command to open the browser
    local open_browser_command = "xdg-open"
    if vim.fn.has("mac") == 1 then
        open_browser_command = "open"
    elseif vim.fn.has("win32") == 1 then
        open_browser_command = "start"
    end
    os.execute(open_browser_command .. " http://localhost:3000")
end

M.disable_atomic_writes = function()
    vim.opt.backupcopy = 'yes'
end
M.disable_atomic_writes()

return M

