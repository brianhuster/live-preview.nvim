const md = window.markdownit({
	html: true,
	highlight: function(str, lang) {
		if (lang && hljs.getLanguage(lang)) {
			try {
				return hljs.highlight(str, { language: lang }).value;
			} catch (__) { }
		}

		return ''; // use external default escaping
	}
});
md.use(injectLinenumbersPlugin);

const render = (text) => {
	const html = md.render(text);
	console.log(html);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').innerHTML;
render(markdownText);


