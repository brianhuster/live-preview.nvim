local M = {}

local uv = vim.uv

local function get_content_type(file_path)
    if file_path:match("%.html$") then
        return 'text/html'
    elseif file_path:match("%.css$") then
        return 'text/css'
    elseif file_path:match("%.js$") then
        return 'application/javascript'
    elseif file_path:match("%.png$") then
        return 'image/png'
    elseif file_path:match("%.jpg$") or file_path:match("%.jpeg$") then
        return 'image/jpeg'
    elseif file_path:match("%.gif$") then
        return 'image/gif'
    else
        return 'application/octet-stream'
    end
end

local function handle_request(client, request, webroot)
    -- Extract the path from the HTTP request
    local _, _, path = request:match("GET (.+) HTTP/1.1")
    path = path or '/' -- Default to root if no path specified

    -- Serve index.html for root requests
    if path == '/' then
        path = '/index.html'
    end

    local file_path = webroot .. path

    -- Attempt to read the file
    local file, err = io.open(file_path, 'rb')
    if not file then
        -- File not found
        local response = "HTTP/1.1 404 Not Found\r\n" ..
            "Content-Type: text/plain\r\n" ..
            "Content-Length: 0\r\n" ..
            "Connection: close\r\n\r\n"
        client:write(response)
        client:shutdown(function()
            client:close()
        end)
        return
    end

    local body = file:read('*a')
    file:close()

    -- Create the correct HTTP/1.1 response
    local response = "HTTP/1.1 200 OK\r\n" ..
        "Content-Type: " .. get_content_type(file_path) .. "\r\n" ..
        "Content-Length: " .. #body .. "\r\n" ..
        "Connection: close\r\n\r\n" ..
        body

    client:write(response)
    client:shutdown(function()
        client:close()
    end)
end

local function handle_client(client)
    local buffer = ""

    client:read_start(function(err, chunk)
        if err then
            print("Read error: " .. err)
            client:close()
            return
        end

        if chunk then
            buffer = buffer .. chunk
            -- Check if the request is complete
            if buffer:match("\r\n\r\n$") then
                handle_request(client, buffer)
            end
        else
            client:close()
        end
    end)
end

function M.serve_file(webroot, ip, port)
    local server = uv.new_tcp()

    server:bind(ip, port)
    server:listen(128, function(err)
        if err then
            print("Listen error: " .. err)
            return
        end

        local client = uv.new_tcp()
        server:accept(cliRequirementsent)
        handle_client(client)
    end)

    print("Server listening on port " .. port)
    uv.run()
end
