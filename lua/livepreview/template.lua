local M = {}

local config = require("livepreview.config")

local html_template = function(body, stylesheet, script_tag)
	local macros = config.config.katex_macros
	local macros_json = macros and vim.json.encode(macros) or "{}"

	local katex_macros_script = ([[
      <script>
        window.LIVE_PREVIEW_KATEX_MACROS = %s;
      </script>
  ]]):format(macros_json)

	return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live preview</title>
]] .. stylesheet .. [[
            <link rel="stylesheet" href="/live-preview.nvim/static/katex/katex.min.css">	
            <script defer src="/live-preview.nvim/static/katex/katex.min.js"></script>
			<script defer src="/live-preview.nvim/static/katex/auto-render.min.js"></script>
            <script src="/live-preview.nvim/static/mermaid/mermaid.min.js"></script>
			<link rel="stylesheet" href="/live-preview.nvim/static/highlight/main.css">
			<script defer src="/live-preview.nvim/static/highlight/highlight.min.js"></script>
]] .. katex_macros_script .. [[
]] .. script_tag .. [[
			<script defer src='/live-preview.nvim/static/ws-client.js'></script>
        </head>

        <body>
            <div class="markdown-body">
]] .. body .. [[
            </div>
			<script defer src="/live-preview.nvim/static/katex/main.js"></script>
            <script defer src="/live-preview.nvim/static/mermaid/main.js"></script>
        </body>
        </html>
    ]]
end

M.md2html = function(md)
	local script = [[
		<script defer src="/live-preview.nvim/static/markdown/line-numbers.js"></script>
		<script defer src="/live-preview.nvim/static/markdown/markdown-it-emoji.min.js"></script>
		<script defer src='/live-preview.nvim/static/markdown/markdown-it.min.js'></script>
		<script type="module" src="/live-preview.nvim/static/markdown/markdown-it-github-alerts-loader.js"></script>
		<script defer src='/live-preview.nvim/static/markdown/main.js'></script>
	]]
	local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/markdown/github-markdown.min.css">
		<link rel="stylesheet" href="/live-preview.nvim/static/markdown/markdown-it-github-alerts/styles/github-base.css">
		<link rel="stylesheet" href="/live-preview.nvim/static/markdown/markdown-it-github-alerts/styles/github-colors-light.css">
		<link rel="stylesheet" href="/live-preview.nvim/static/markdown/markdown-it-github-alerts/styles/github-colors-dark-media.css">
    ]]
	return html_template(md, stylesheet, script)
end

M.adoc2html = function(adoc)
	local script = [[
		<script defer src="/live-preview.nvim/static/asciidoc/asciidoctor.min.js"></script>
        <script defer src='/live-preview.nvim/static/asciidoc/main.js'></script>
    ]]
	local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/asciidoc/asciidoctor.min.css">
    ]]
	return html_template(adoc, stylesheet, script)
end

M.svg2html = function(svg)
	svg = svg:gsub(
		"</svg>",
		"<script href='/live-preview.nvim/static/ws-client.js' type='application/ecmascript'></script></svg>"
	)
	return [[
		<!DOCTYPE html>
		<html lang="en">

		<head>
		</head>

		<body>
			<div class='markdown-body'>
]] .. svg .. [[
			</div>
		</body>
		</html>
	]]
end

M.toHTML = function(text, filetype)
	if filetype == "markdown" then
		return M.md2html(text)
	elseif filetype == "asciidoc" then
		return M.adoc2html(text)
	elseif filetype == "svg" then
		return M.svg2html(text)
	end
end

M.handle_body = function(data)
	local ws_script = "<script src='/live-preview.nvim/static/ws-client.js'></script>"
	local body
	if data:match("<head>") then
		body = data:gsub("<head>", "<head>" .. ws_script)
	else
		body = ws_script .. data
	end
	return body
end

return M
