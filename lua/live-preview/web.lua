local M = {}

M.md_html = function(md)
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
    return [[
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #ffffff;
            color: #24292e;
        }
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 980px;
            margin: 0 auto;
            padding: 45px;
        }
        .markdown-body table {
            display: block;
            width: 100%;
            overflow: auto;
        }
        .markdown-body table th {
            font-weight: 600;
        }
        .markdown-body table th, .markdown-body table td {
            padding: 6px 13px;
            border: 1px solid #dfe2e5;
        }
        .markdown-body table tr {
            background-color: #ffffff;
            border-top: 1px solid #c6cbd1;
        }
        .markdown-body table tr:nth-child(2n) {
            background-color: #f6f8fa;
        }
        .markdown-body blockquote {
            padding: 0 1em;
            color: #6a737d;
            border-left: 0.25em solid #dfe2e5;
        }
        .markdown-body code {
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 85%;
            background-color: rgba(27,31,35,0.05);
            border-radius: 3px;
        }
        .markdown-body pre {
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #f6f8fa;
            border-radius: 3px;
        }
        .markdown-body pre code {
            display: inline;
            padding: 0;
            margin: 0;
            font-size: 100%;
            line-height: inherit;
            word-wrap: normal;
            background-color: transparent;
            border: 0;
        }
        .markdown-body h1, .markdown-body h2, .markdown-body h3, .markdown-body h4, .markdown-body h5, .markdown-body h6 {
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
            line-height: 1.25;
        }
        .markdown-body h1 {
            font-size: 2em;
        }
        .markdown-body h2 {
            font-size: 1.5em;
        }
        .markdown-body h3 {
            font-size: 1.25em;
        }
        .markdown-body h4 {
            font-size: 1em;
        }
        .markdown-body h5 {
            font-size: 0.875em;
        }
        .markdown-body h6 {
            font-size: 0.85em;
            color: #6a737d;
        }
        .markdown-body p {
            margin-top: 0;
            margin-bottom: 16px;
        }
        .markdown-body ul, .markdown-body ol {
            padding-left: 2em;
            margin-top: 0;
            margin-bottom: 16px;
        }
        .markdown-body li {
            word-wrap: break-all;
        }
        .markdown-body li>p {
            margin-top: 16px;
        }
        .markdown-body li+li {
            margin-top: 0.25em;
        }
        .markdown-body dl {
            padding: 0;
        }
        .markdown-body dl dt {
            padding: 0;
            margin-top: 16px;
            font-size: 1em;
            font-style: italic;
            font-weight: 600;
        }
        .markdown-body dl dd {
            padding: 0 16px;
            margin-bottom: 16px;
        }
        .markdown-body hr {
            height: 0.25em;
            padding: 0;
            margin: 24px 0;
            background-color: #e1e4e8;
            border: 0;
        }
        .markdown-body blockquote {
            margin-top: 0;
            margin-bottom: 16px;
        }
        .markdown-body a {
            color: #0366d6;
            text-decoration: none;
        }
        .markdown-body a:hover {
            text-decoration: underline;
        }
        .markdown-body img {
            max-width: 100%;
            box-sizing: border-box;
            background-color: #ffffff;
        }]]
end

M.ws_client = function()
    return [[
        const wsUrl = getWebSocketUrl();
        let socket = new WebSocket(wsUrl);
        let connected = true;

        function getWebSocketUrl() {
            const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
            const hostname = window.location.hostname;
            const port = window.location.port ? `:${window.location.port}` : "";
            return `${protocol}//${hostname}${port}`;
        }

        async function connectWebSocket() {
            socket = new WebSocket(wsUrl);

            socket.onopen = () => {
                if (!connected) {
                    window.location.reload();
                }
                console.log("Connected to server");
                console.log("connected: ", connected);
            };

            socket.onmessage = (event) => {
                const message = JSON.parse(event.data);

                if (message.type === 'reload' || event.data === 'reload') {
                    console.log('Reload message received');
                    window.location.reload(); // Reload the page
                }
            };

            socket.onclose = () => {
                connected = false;
                console.log("Disconnected from server");
                console.log("connected: ", connected);
            };

            socket.onerror = (error) => {
                connected = false;
                console.error("WebSocket error:", error);
                console.log("connected: ", connected);
            };
        }

        function main() {
            connectWebSocket();
            setInterval(() => {
                if (!connected) {
                    connectWebSocket();
                }
            }, 10);
        }

        window.onload = main;
    ]]
end

return M
