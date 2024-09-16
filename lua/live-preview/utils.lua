local M = {}

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
    if win.fn.has("win32") == 1 then
        shell = "pwsh"
    end

    local result = {}

    local handle = uv.spawn(shell, {
        args = { '-c', cmd },
        stdio = { stdin or nil, stdout, stderr },
    }, function(code, signal)
        print("Exit code:", code)
        print("Signal:", signal)
        result.code = code
        result.signal = signal
        handle:close()
    end)

    uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            print("STDOUT:", data)
            result.stdout = data
        end
    end)

    uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            print("STDERR:", data)
            result.stderr = data
        end
    end)
    return result
end

return M
