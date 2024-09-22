local M = {}

local html_template = function(body, stylesheet, script_tag)
    return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live preview</title>
]] .. stylesheet .. [[
        </head>

        <body>
            <div class="markdown-body">
]] .. body .. [[
            </div>
]] .. script_tag .. [[
        </body>

        </html>

    ]]
end

M.md2html = function(md)
    local script = [[
        <script src="live-preview.nvim/static/parsers/marked.min.js"></script>
        <script>
            const markdownText = document.querySelector('.markdown-body').innerHTML;
            const html = marked.parse(markdownText);
            document.querySelector('.markdown-body').innerHTML = html;
        </script>
    ]]
    local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/github-markdown.min.css">
    ]]
    return html_template(md, stylesheet, script)
end


M.adoc2html = function(adoc)
    local script = [[
        <script type="module">
            import Asciidoctor from '/live-preview.nvim/static/parsers/asciidoctor.js'
            const asciidoctor = Asciidoctor();
            const adoc = document.querySelector('.markdown-body').innerHTML;
            const html = asciidoctor.convert(adoc);
            document.querySelector('.markdown-body').innerHTML = html;
        </script>
    ]]
    local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/asciidoctor.min.css">
    ]]
    return html_template(adoc, stylesheet, script)
end



M.toHTML = function(text, filetype)
    if filetype == 'markdown' then
        return M.md2html(text)
    elseif filetype == 'asciidoc' then
        return M.adoc2html(text)
    end
end


M.handle_body = function(data)
    local ws_script = "<script src='/live-preview.nvim/static/ws-client.min.js'></script>"
    return ws_script .. data
end


return M
