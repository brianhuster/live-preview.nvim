local uv = vim.uv

local function handle_client(client)
    print("New client connected")

    client:read_start(function(err, chunk)
        if err then
            print("Read error: " .. err)
            client:close()
            return
        end

        if chunk then
            -- For simplicity, we're not parsing WebSocket frames here
            -- Just echoing back whatever we receive
            print("Received data from client")
            client:write(chunk)
        else
            -- chunk is nil when the client has disconnected
            print("Client disconnected")
            client:close()
        end
    end)
end

local server = uv.new_tcp()
local port = 8080

server:bind("0.0.0.0", port)
server:listen(128, function(err)
    if err then
        print("Listen error: " .. err)
        return
    end

    local client = uv.new_tcp()
    server:accept(client)
    handle_client(client)
end)

print("Server listening on port " .. port)

uv.run()
