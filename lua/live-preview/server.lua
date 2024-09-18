local M = {}

local uv = vim.uv
local read_file = require('live-preview.utils').uv_read_file
local sha1 = require('live-preview.utils').sha1
local hex2bin = require('live-preview.utils').hex2bin
local ws_client = require('live-preview.web').ws_client
local ws_script = "<script>" .. ws_client() .. "</script>"
local webroot = "."
local html_content = nil
M.server = uv.new_tcp()


local handle_body = function(data)
    if data:find("</body>") then
        data = data:gsub("</body>", ws_script .. "</body>")
    elseif data:find("</html>") then
        data = data:gsub("</html>", ws_script .. "</html>")
    else
        data = data .. ws_script
    end
    return data
end


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


local function send_http_response(client, status, content_type, body)
    -- status can be something like "200 OK", "404 Not Found", etc.
    local response = "HTTP/1.1 " .. status .. "\r\n" ..
        "Content-Type: " .. content_type .. "\r\n" ..
        "Content-Length: " .. #body .. "\r\n" ..
        "Connection: close\r\n\r\n" ..
        body
    print(response)

    client:write(response)
end


local function websocket_handshake(client, request)
    local key = request:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
    if not key then
        print("Invalid WebSocket request from client")
        client:close()
        return
    end

    local accept = sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
    accept = vim.base64.encode(accept)
    accept = vim.trim(accept)

    local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
        "Upgrade: websocket\r\n" ..
        "Connection: Upgrade\r\n" ..
        "Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
    client:write(response)
end


local function handle_request(client, request)
    if request:match("Upgrade: websocket") then
        websocket_handshake(client, request)
        return
    end
    -- Extract the path from the HTTP request
    local _, _, path = request:match("GET (.+) HTTP/1.1")
    path = path or '/'
    if path == '/' then
        if html_content then
            send_http_response(client, '200 OK', 'text/html', html_content)
            return
        else
            path = '/index.html'
        end
    end

    local file_path = webroot .. path
    local body = read_file(file_path)
    print(body)
    if not body then
        send_http_response(client, '404 Not Found', 'text/plain', '404 Not Found')
        local function leftrotate(x, n)
            return bit.bor(bit.lshift(x, n), bit.rshift(x, 32 - n))
        end
        return
    end
    body = handle_body(body)
    send_http_response(client, '200 OK', get_content_type(file_path), body)
end


local function handle_client(client)
    local buffer = ""

    client:read_start(function(err, chunk)
        if err then
            print("Read error: " .. err)
            client:close()
            return
        end

        if chunk thensocket.onmessage = (event) => {
                const message = JSON.parse(event.data);

                if (message.type === 'reload' || event.data === 'reload') {
                    console.log('Reload message received');
                    window.location.reload(); // Reload the page
                }
            };
            buffer = buffer .. chunk
            -- Check if the request is complete
            if buffer:match("\r\n\r\n$") then
                if html_content then
                    handle_request(client, buffer, html_content)
                else
                    handle_request(client, buffer)
                end
            else
                print("Incomplete request")
            end
        else
            client:close()
        end
    end)
end


local function websocket_send(client, message)
    local frame = string.char(0x81) .. string.char(#message) .. message
    client:write(frame)
end


local function watch_dir(dir, client)
    local watcher = uv.new_fs_event()
    watcher:start(dir, {}, function(err, filename, event)
        if err then
            print("Watch error: " .. err)
            return
        end
        websocket_send(client, "reload")
    end)
end


function M.start(ip, port, options)
    webroot = options.webroot or '.'
    html_content = options.html_content
    if html_content then
        html_content = handle_body(html_content)
    end

    M.server:bind(ip, port)
    M.server:listen(128, function(err)
        if err then
            print("Listen error: " .. err)
            return
        end

        local client = uv.new_tcp()
        M.server:accept(client)
        handle_client(client)
        watch_dir(webroot, client)
    end)

    print("Server listening on port " .. port)
    uv.run()
end

M.stop = function()
    M.server:close()
end

return M
