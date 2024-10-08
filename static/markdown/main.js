import { marked } from '/live-preview.nvim/static/markdown/marked.min.js';

const renderer = {
	code({ text, lang, escaped }) {
		const langString = (lang || '').match(/^\S*/)?.[0];
		const code = text.replace(/\n$/, '') + '\n';
		if (!langString) {
			return '<pre><code>' + code + '</code></pre>';
		}
		return `<pre class="language-${langString}">${code}</pre>`
	},
};

marked.use({ renderer });

const render = (text) => {
	const html = marked.parse(markdownText, { lineNumbers: true });
	console.log(html);
	document.querySelector('.markdown-body').innerHTML = html;
}

const markdownText = document.querySelector('.markdown-body').innerHTML;
render(markdownText);

