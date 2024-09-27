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
            <script src='/live-preview.nvim/static/ws-client.min.js'></script>"
            <link rel="stylesheet" href="/live-preview.nvim/static/katex/katex.min.css">
            <script defer src="/live-preview.nvim/static/katex/katex.min.js"></script>
            <script defer src="/live-preview.nvim/static/katex/auto-render.min.js" onload="renderMathInElement(document.body);"></script>
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
        <script src='/live-preview.nvim/static/markdown/marked.min.js'></script>
        <script>
            const markdownText = document.querySelector('.markdown-body').innerHTML;
            const html = marked.parse(markdownText);
            document.querySelector('.markdown-body').innerHTML = html;
        </script>
        <script type="module">
            import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.2.1/+esm'
        </script>
    ]]
    local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/markdown/github-markdown.min.css">
    ]]
    return html_template(md, stylesheet, script)
end


M.adoc2html = function(adoc)
    local script = [[
        <script type="module">
            import Asciidoctor from '/live-preview.nvim/static/asciidoc/asciidoctor.min.js'
            const asciidoctor = Asciidoctor();
            const adoc = document.querySelector('.markdown-body').innerHTML;
            const html = asciidoctor.convert(adoc);
            document.querySelector('.markdown-body').innerHTML = html;

            document.addEventListener("DOMContentLoaded", function () {
                renderMathInElement(document.body, {
                    delimiters: [
                        { left: "$$", right: "$$", display: true },
                        { left: "$", right: "$", display: false }
                    ]
                });
            });
        </script>
    ]]
    local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/asciidoc/asciidoctor.min.css">
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
    if data:match("<head>") then
        local body = data:gsub("<head>", "<head>" .. ws_script)
    else
        local body = ws_script .. data
    end
end


return M
