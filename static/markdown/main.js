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

// Use markdown-it-katex plugin to handle math rendering during markdown parsing
// This prevents markdown-it from corrupting LaTeX syntax before KaTeX can render it
md.use(markdownitKatex);

// Only the fences are replaced so that line numbers for sync scroll stay the same
const livepreview_frontmatter = (text) =>
	text.replace(/^(\n?)---(\r?\n[\s\S]*?\r?\n)(?:---|\.\.\.)(?=\r?\n|$)/, '$1```yaml$2```');

const livepreview_render = (text) => {
	const html = md.render(livepreview_frontmatter(text));
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText);


