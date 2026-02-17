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
	console.log("=== Input to md.render() ===");
	console.log(text);
	console.log("=== Checking for backslashes in input ===");
	console.log("Input contains \\begin:", text.includes("\\begin"));
	
	const html = md.render(text);
	console.log("=== Output from md.render() ===");
	console.log(html);
	console.log("=== Checking for backslashes in output ===");
	console.log("Output contains \\begin:", html.includes("\\begin"));
	console.log("Output contains begin:", html.includes("begin"));
	
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


