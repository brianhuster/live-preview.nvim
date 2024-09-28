const renderer = new marked.Renderer();
renderer.code = (code, language) => {
    return `<pre class="language-${language}">${code}</pre>`;
};

marked.use({ renderer });

const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

