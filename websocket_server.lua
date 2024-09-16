local uv = vim.loop

local function handle_connection(client)
    local function on_read(err, data)
        if err then
            print("Read error:", err)
            client:shutdown()
            return
        end
        if data then
            print("Received data:", data)
            -- Echo data back to the client
            client:write(data)
        else
            -- Connection closed by client
            print("Client disconnected")
            client:shutdown()
        end
    end

    -- Simulate onopen event
    print("Client connected")
    client:read_start(on_read)
end

local function start_server()
    local server = uv.new_tcp()
    server:bind("0.0.0.0", 8080)
    server:listen(128, function(err)
        if err then
            print("Listen error:", err)
            return
        end
        local client = uv.new_tcp()
        server:accept(client)
        handle_connection(client)
    end)
end

start_server()
print('TCP server started on tcp://localhost:8080')
