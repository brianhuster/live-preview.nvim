import Asciidoctor from '/live-preview.nvim/static/asciidoc/asciidoctor.min.js'
const asciidoctor = Asciidoctor();
const adoc = document.querySelector('.markdown-body').innerHTML;
const html = asciidoctor.convert(adoc);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

document.addEventListener("DOMContentLoaded", function() {
    renderMathInElement(document.body, {
        delimiters: [
            { left: "$$", right: "$$", display: true },
            { left: "$", right: "$", display: false }
        ]
    });
});

