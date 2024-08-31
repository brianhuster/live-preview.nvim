const express = require("express");
const fs = require("fs");
const path = require("path");
const marked = require("marked");
const http = require("http");
const WebSocket = require("ws");

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

const port = process.argv[3] || 3000;
const filePath = process.argv[2];
const directory = path.dirname(filePath);

app.use(express.static(directory));
app.use(express.static("./server/public"));

const js_script = `
    <script src="script.js"></script>
`;

wss.on("connection", (ws) => {
    console.log("New WebSocket connection");

    ws.on("close", () => {
        console.log("WebSocket connection closed");
    });

    ws.on("error", (error) => {
        console.error("WebSocket error:", error);
    });
});

app.get("/", (req, res) => {
    if (!filePath) {
        res.status(400).send("No file path provided");
        return;
    }

    const extname = path.extname(filePath);

    if (extname === ".md") {
        fs.readFile(filePath, "utf8", (err, data) => {
            if (err) {
                res.status(500).send("Error reading the Markdown file");
                return;
            }
            const html = marked.parse(data);
            res.render("md", { html, js_script });
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