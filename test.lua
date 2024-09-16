local uv = vim.uv
local stdin = uv.new_pipe()
local stdout = uv.new_pipe()
local stderr = uv.new_pipe()

print("stdin", stdin)
print("stdout", stdout)
print("stderr", stderr)

local handle, pid = uv.spawn("ls -a", {
    stdio = { stdin, stdout, stderr }
}, function(code, signal) -- on exit
    print("exit code", code)
    print("exit signal", signal)
end)

print("process opened", handle, pid)

uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
        print("stdout chunk", stdout, data)
    else
        print("stdout end", stdout)
    end
end)

uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
        print("stderr chunk", stderr, data)
    else
        print("stderr end", stderr)
    end
end)

uv.write(stdin, "Hello World")

uv.shutdown(stdin, function()
    print("stdin shutdown", stdin)
    uv.close(handle, function()
        print("process closed", handle, pid)
    end)
end)
