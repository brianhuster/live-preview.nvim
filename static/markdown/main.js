const renderer = new marked.Renderer();

renderer.code = function(code, language, escaped = false) {
    if (this.options.highlight) {
        const out = this.options.highlight(code, language);
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
});
const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

