local M = {}
local plugin_path = require('live-preview.utils').get_plugin_path()
local read_file = require('live-preview.utils').uv_read_file

M.md2html = function(md)
    return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Markdown Viewer</title>
            <style>
                ]] .. M.md_css() .. [[
            </style>
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
        </head>

        <body>
            <div class="markdown-body" id='markdown-body'>
]] .. md .. [[
            </div>
            <script>
                const markdownText = document.getElementById('markdown-body').innerHTML;
                const html = marked.parse(markdownText);
                document.getElementById('markdown-body').innerHTML = html;
            </script>

        </body>

        </html>

    ]]
end


M.md_css = function()
    local data = read_file(vim.fs.joinpath(plugin_path, "static/md.css"))
    print("css", data)
    return data
end

M.ws_client = function()
    local data = read_file(vim.fs.joinpath(plugin_path, "static/ws-client.js"))
    return data
end

return M
