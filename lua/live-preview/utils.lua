local M = {}

local uv = vim.uv

if not bit then
    bit = require("bit")
end

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


M.sha1 = function(data)
    local h0 = 0x67452301
    local h1 = 0xEFCDAB89
    local h2 = 0x98BADCFE
    local h3 = 0x10325476
    local h4 = 0xC3D2E1F0

    local function leftrotate(x, n)
        return bit.bor(bit.lshift(x, n), bit.rshift(x, 32 - n))
    end


    local function preprocess(data)
        local bitlen = #data * 8
        data = data .. "\128"
        while (#data % 64) ~= 56 do
            data = data .. "\0"
        end
        for i = 1, 8 do
            data = data .. string.char(bit.band(bit.rshift(bitlen, (8 - i) * 8), 0xFF))
        end
        return data
    end

    local function processblock(block)
        local w = {}
        for i = 1, 16 do
            w[i] = 0
            for j = 0, 3 do
                w[i] = bit.bor(bit.lshift(w[i], 8), block:byte((i - 1) * 4 + j + 1))
            end
        end
        for i = 17, 80 do
            w[i] = leftrotate(bit.bxor(w[i - 3], w[i - 8], w[i - 14], w[i - 16]), 1)
        end

        local a, b, c, d, e = h0, h1, h2, h3, h4

        for i = 1, 80 do
            local f, k
            if i <= 20 then
                f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d))
                k = 0x5A827999
            elseif i <= 40 then
                f = bit.bxor(b, c, d)
                k = 0x6ED9EBA1
            elseif i <= 60 then
                f = bit.bor(bit.band(b, c), bit.band(b, d), bit.band(c, d))
                k = 0x8F1BBCDC
            else
                f = bit.bxor(b, c, d)
                k = 0xCA62C1D6
            end
            local temp = leftrotate(a, 5) + f + e + k + w[i]
            e = d
            d = c
            c = leftrotate(b, 30)
            b = a
            a = temp
        end

        h0 = bit.band(h0 + a, 0xFFFFFFFF)
        h1 = bit.band(h1 + b, 0xFFFFFFFF)
        h2 = bit.band(h2 + c, 0xFFFFFFFF)
        h3 = bit.band(h3 + d, 0xFFFFFFFF)
        h4 = bit.band(h4 + e, 0xFFFFFFFF)
    end

    data = preprocess(data)
    for i = 1, #data, 64 do
        processblock(data:sub(i, i + 63))
    end

    return string.format("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
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
