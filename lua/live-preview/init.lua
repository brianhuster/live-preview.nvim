-- ~/.local/share/nvim/lazy/live-preview.nvim/live-preview.lua

local M = {}

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


function M.preview_file()
    print("live-preview called")
    local filename = vim.fn.expand('%:p')
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
    local command = string.format("nodemon --exec 'node ~/.local/share/nvim/lazy/live-preview.nvim/server.js %s'", filename)
    vim.fn.jobstart(command, {
    on_exit = function(_, code)
      if code ~= 0 then
        print("Error starting the server")
      end
    end
    })

    -- Open browser with the rendered file
    local open_browser_command = "xdg-open"
    if vim.fn.has("mac") == 1 then
    open_browser_command = "open"
    elseif vim.fn.has("win32") == 1 then
    open_browser_command = "start"
    end

    os.execute(open_browser_command .. " http://localhost:3000")
end

return M

