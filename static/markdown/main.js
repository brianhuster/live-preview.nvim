const renderer = {
    code({ tokens, lang }) {
        const text = this.parser.parseInline(tokens);

        return `
            <pre class="language-${lang}">${lang}</pre>
        `;
    }
};

marked.use({ renderer });

const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

