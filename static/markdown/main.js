const renderer = new marked.Renderer();

renderer.code = function(code, language, escaped = false) {
    console.log("Original code:", code);
    console.log("Language:", language);

    if (this.options.highlight) {
        const out = this.options.highlight(code, language);
        console.log("Highlighted code:", out);
        if (out != null && out !== code) {
            escaped = true;
            code = out;
        }
    }

    if (!language) {
        return '<pre><code>' + code + '</code></pre>';
    }

    return '<pre><code class="language-' + language + '">' + code + '</code></pre>\n';
};

marked.setOptions({
    renderer: renderer,
    sanitize: false, // Disable sanitization to prevent escaping
    highlight: function(code, language) {
        // You can add your syntax highlighting logic here
        return code;
    }
});


const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

