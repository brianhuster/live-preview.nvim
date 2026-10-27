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

// Generate anchor IDs for Markdown headings
md.core.ruler.push("heading_anchors", (state) => {
	const usedIds = new Set();
	const tokens = state.tokens;

	for (let i = 0; i < tokens.length; i++) {
		const token = tokens[i];

		if (token.type !== "heading_open") continue;

		const heading = tokens[i + 1];
		if (!heading || heading.type !== "inline") continue;

		const visibleText = (heading.children || [])
			.map((child) => {
				if (["text", "code_inline", "emoji", "image"].includes(child.type)) {
					return child.content;
				}

				if (child.type === "softbreak" || child.type === "hardbreak") {
					return " ";
				}

				return "";
			})
			.join("");

		const baseId = visibleText
			.trim()
			.toLowerCase()
			.replace(/[^\p{L}\p{N}\p{M}\s_-]/gu, "")
			.replace(/\s+/g, "-") || "section";


		let id = baseId;
		let suffix = 1;

		while (usedIds.has(id)) {
			id = `${baseId}-${suffix}`;
			suffix++;
		}

		usedIds.add(id);
		token.attrSet("id", id);
	}
});


const livepreview_render = (text) => {
	const html = md.render(text);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText);


