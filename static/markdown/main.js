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
md.use(livepreview_injectLinenumbersPlugin);

md.use(markdownitEmoji);

const livepreview_render = (text) => {
	const html = md.render(text);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText);

// Render KaTeX after markdown is processed
// Note: Must call directly here because DOMContentLoaded has already fired
// when deferred scripts execute
if (typeof livepreview_renderKatex !== "undefined") {
	livepreview_renderKatex();
}


