const renderer = new marked.Renderer();
renderer.code = function(code, language) {
    const langClass = language ? `language-${language}` : '';
    return `<pre><code class="${langClass}">${code}</code></pre>`;
};

marked.setOptions({
    renderer: renderer,
    gfm: true,
    breaks: true
});
const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

