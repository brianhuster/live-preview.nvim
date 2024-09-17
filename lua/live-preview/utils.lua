local M = {}

local uv = vim.uv

function M.get_plugin_path()
    local full_path = utils.get_path_lua_file()
    if not full_path then
        return nil
    end
    local subpath = "/lua/live-preview/utils.lua"
    return M.get_parent_path(full_path, subpath)
end

function M.uv_read_file(file_path)
    local fd = uv.fs_open(file_path, 'r', 438) -- 438 is decimal for 0666
    if not fd then
        print("Error opening file: " .. file_path)
        return nil
    end

    local stat = uv.fs_fstat(fd)
    if not stat then
        print("Error getting file info: " .. file_path)
        return nil
    end

    local data = uv.fs_read(fd, stat.size, 0)
    if not data then
        print("Error reading file: " .. file_path)
        return nil
    end

    uv.fs_close(fd)
    return data
end

M.get_path_lua_file = function()
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

M.get_parent_path = function(full_path, subpath)
    local escaped_subpath = subpath:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    local pattern = "(.*)" .. escaped_subpath
    local parent_path = full_path:match(pattern)
    return parent_path
end


M.sha1 = function(data)
    local command = "echo -n '" .. data .. "' | shasum | awk '{print $1}'"
    local result
    if uv.os_uname().version:match("Windows") then
        command = string.format([[
            $data = "%s"
            $sha1 = [System.Security.Cryptography.SHA1]::Create()
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($data)
            $hash = $sha1.ComputeHash($bytes)
            $hashString = [BitConverter]::ToString($hash) -replace '-'
            $hashString
        ]], data)
    end

    result = M.await_term_cmd(command)

    return result.stdout:gsub("%s+", "")
end

M.term_cmd = function(cmd)
    local shell = "sh"
    if uv.os_uname().version:match("Windows") then
        shell = "pwsh"
    end

    local on_exit = function(result)
        return result
    end

    vim.system({ shell, '-c', cmd }, { text = true }, { on_exit })
end

M.await_term_cmd = function(cmd)
    local shell = "sh"
    if uv.os_uname().version:match("Windows") then
        shell = "pwsh"
    end

    local result = vim.system({ shell, '-c', cmd }, { text = true }):wait()
    return result
end

M.hex2bin = function(hex)
    local binary = ""
    for i = 1, #hex, 2 do
        local byte = hex:sub(i, i + 1)
        binary = binary .. string.char(tonumber(byte, 16))
    end
    return binary
end


M.open_browser = function(link)
    vim.ui.open(link)
end


M.kill_port = function(port)
    local kill_command = string.format(
        "lsof -i TCP:%d | grep -v 'neovim' | grep LISTEN | awk '{print $2}' | xargs kill -9",
        port
    )

    if vim.uv.os_uname().version:match("Windows") then
        kill_command = string.format(
            [[
                @echo off
                setlocal

                for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%d') do (
                    for /f "tokens=2 delims=," %%b in ('tasklist /fi "PID eq %%a" /fo csv /nh') do (
                        if /i not "%%b"=="neovim.exe" (
                            echo Killing PID %%a (Process Name: %%b)
                            taskkill /PID %%a /F
                        )
                    )
                )

                endlocal
            ]],
            port
        )
    end
    os.execute(kill_command)
end


return M
