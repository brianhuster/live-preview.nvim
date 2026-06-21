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

// Capture frontmatter content during render via the front-matter plugin callback
let _frontmatter = null;
md.use(markdownitFrontMatter, (fm) => {
	_frontmatter = fm;
});

function buildFrontmatterHtml(yamlText, open) {
	const escaped = yamlText
		.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;');
	const openAttr = open ? ' open' : '';
	return `<details class="frontmatter-block"${openAttr}>` +
		`<summary>Document metadata</summary>` +
		`<pre><code class="language-yaml">${escaped}</code></pre>` +
		`</details>`;
}

const livepreview_render = (text) => {
	// Persist open/closed state across live re-renders
	const existing = document.querySelector('.frontmatter-block');
	const wasOpen = existing ? existing.open : false;

	_frontmatter = null;
	const html = md.render(text); // front-matter plugin callback sets _frontmatter
	const fmHtml = _frontmatter ? buildFrontmatterHtml(_frontmatter, wasOpen) : '';
	document.querySelector('.markdown-body').innerHTML = fmHtml + html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText.trim());


