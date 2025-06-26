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

const livepreview_render = () => {
	document.querySelector('.markdown-body').innerHTML = md.render(document.querySelector('.markdown-body').innerHTML);
	hljs.highlightAll();
}

livepreview_render();
