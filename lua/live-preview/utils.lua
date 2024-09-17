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

M.run_shell_command = function(cmd)
    local uv = vim.uv
    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()
    local shell = "sh"
    if uv.os_uname().version:match("Windows") then
        shell = "pwsh"
    end

    local result = {}

    local handle = uv.spawn(shell, {
        args = { '-c', cmd },
        stdio = { stdin, stdout, stderr },
    }, function(code, signal)
        result.code = code
        result.signal = signal
        handle:close()
    end)

    uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            result.stdout = data
        end
    end)

    uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            result.stderr = data
        end
    end)
    return result
end

M.sha1 = function(data)
    local command = "echo -n '" .. data .. "' | shasum | awk '{print $1}'"
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

    local result = M.run_shell_command(command)

    while result.stdout == nil do
        vim.wait(10)
    end
    return result.stdout:gsub("%s+", "")
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


return M
