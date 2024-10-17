// const renderer = {
// 	code({ text, lang, escaped }) {
// 		const langString = (lang || '').match(/^\S*/)?.[0];
// 		const code = text.replace(/\n$/, '') + '\n';
// 		if (!langString) {
// 			return '<pre><code>' + code + '</code></pre>';
// 		}
// 		return `<pre class="language-${langString}">${code}</pre>`
// 	},
// };
//
// marked.use({ renderer });
//
// const render = (text) => {
// 	const html = marked.parse(text, { lineNumbers: true });
// 	console.log(html);
// 	document.querySelector('.markdown-body').innerHTML = html;
// }
//
// const markdownText = document.querySelector('.markdown-body').innerHTML;
// render(markdownText);

const md = window.markdownit({
	highlight: function(str, lang) {
		if (lang && hljs.getLanguage(lang)) {
			try {
				return hljs.highlight(str, { language: lang }).value;
			} catch (__) { }
		}

		return ''; // use external default escaping
	}
});

const render = (text) => {
	const html = md.render(text, { lineNumbers: true });
	console.log(html);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').innerHTML;
render(markdownText);


