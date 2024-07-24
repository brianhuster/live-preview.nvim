// ~/.config/nvim/plugged/markdown-viewer/server.js

const express = require('express');
const fs = require('fs');
const path = require('path');
const marked = require('marked');
const { exec } = require('child_process');

const app = express();
const port = 3000;

app.use(express.static('public'));

app.get('/', (req, res) => {
  const filePath = process.argv[2];
  
  if (!filePath) {
    res.status(400).send('No file path provided');
    return;
  }

  const extname = path.extname(filePath);

  if (extname === '.md') {
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        res.status(500).send('Error reading the Markdown file');
        return;
      }

      const html = marked(data);
      res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Markdown Viewer</title>
          <link rel="stylesheet" href="/styles.css">
        </head>
        <body>
          ${html}
        </body>
        </html>
      `);
    });
  } else if (extname === '.html') {
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        res.status(500).send('Error reading the HTML file');
        return;
      }

      res.send(data);
    });
  } else if (extname === '.css') {
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        res.status(500).send('Error reading the CSS file');
        return;
      }

      res.send(`
        <html>
        <head>
          <title>CSS Preview</title>
          <style>${data}</style>
        </head>
        <body>
          <h1>CSS Preview</h1>
          <p>Preview of the CSS file.</p>
        </body>
        </html>
      `);
    });
  } else {
    res.status(400).send('Unsupported file type');
  }
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});

