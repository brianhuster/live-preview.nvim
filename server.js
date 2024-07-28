// ~/.config/nvim/plugged/markdown-viewer/server.js

const express = require("express");
const fs = require("fs");
const path = require("path");
const marked = require("marked");
const http = require("http");
const socketIO = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = socketIO(server);

const port = process.argv[3] || 3000;
const filePath = process.argv[2];
const directory = path.dirname(filePath);

app.use(express.static(directory));
app.use(
    express.static(path.join(__dirname, "node_modules/socket.io/client-dist"))
);

const js_script = `
<script src="socket.io.js"></script>
<script>
    let status = 'connected';
    const socket = io({
        reconnection: true
    });
  
    socket.on('connect', () => {
        console.log('Connected to server');
        if (status === 'disconnected'){
            window.location.reload();
        }
    });
  
    socket.on('disconnect', () => {
        console.log('Disconnected from server');
        status = 'disconnected';
    });
</script>
`;

app.use(express.static("public"));

app.get("/", (req, res) => {
    if (!filePath) {
        res.status(400).send("No file path provided");
        return;
    }

    const extname = path.extname(filePath);

    if (extname === ".md") {
        fs.readFile(
            path.join(__dirname, "assets/md.css"),
            "utf8",
            (err, data) => {
                if (err) {
                    console.log("Error reading the default CSS file");
                    return;
                }
                md_css_style = data;
            }
        );

        fs.readFile(filePath, "utf8", (err, data) => {
            if (err) {
                res.status(500).send("Error reading the Markdown file");
                return;
            }

            const html = marked.parse(data);
            res.send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Markdown Viewer</title>
              <style>
                ${md_css_style}
              </style>
            </head>
            <body>
              <div class="markdown-body">
                ${html}
              </div>
              ${js_script}
            </body>
            </html>
            `);
        });
    } else if (extname === ".html") {
        fs.readFile(filePath, "utf8", (err, data) => {
            if (err) {
                res.status(500).send("Error reading the HTML file");
                return;
            }
            if (data.includes("</body>")) {
                data = data.replace("</body>", `${js_script}</body>`);
            } else if (data.includes("</html>")) {
                data = data.replace("</html>", `${js_script}</html>`);
            } else {
                data += `${js_script}`;
            }
            res.send(data);
        });
    } else {
        res.status(400).send("Unsupported file type " + extname);
    }
});

server.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
