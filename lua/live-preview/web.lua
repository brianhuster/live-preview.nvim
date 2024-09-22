local M = {}

local html_template = function(body, script_tag)
    return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live preview</title>
            <link rel="stylesheet" href="/live-preview.nvim/static/github-markdown.css">
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
        <script src="live-preview.nvim/parsers/marked.min.js"></script>
        <script>
            const markdownText = document.querySelector('.markdown-body').innerHTML;
            const html = marked.parse(markdownText);
            document.querySelector('.markdown-body').innerHTML = html;
        </script>
    ]]
    return html_template(md, script)
end


M.adoc2html = function(adoc)
    local script = [[
        <script type="module">
            import Asciidoctor from '/live-preview.nvim/parsers/asciidoctor.js'
            const asciidoctor = Asciidoctor();
            const adoc = document.querySelector('.markdown-body').innerHTML;
            const html = asciidoctor.convert(adoc);
            document.querySelector('.markdown-body').innerHTML = html;
        </script>
    ]]
    return html_template(adoc, script)
end


M.toHTML = function(text, filetype)
    if filetype == 'markdown' then
        return M.md2html(text)
    elseif filetype == 'asciidoc' then
        return M.adoc2html(text)
    end
end


return M
