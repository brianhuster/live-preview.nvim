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
	console.log("=== Checking for math markers ===");
	console.log("Contains $:", text.includes("$"));
	console.log("Contains \\begin:", text.includes("\\begin"));
	
	const html = md.render(text);
	console.log("=== Output from md.render() ===");
	console.log(html);
	console.log("=== Checking output for math markers ===");
	console.log("Output contains $:", html.includes("$"));
	console.log("Output contains \\begin:", html.includes("\\begin"));
	
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
	
	console.log("=== About to call KaTeX render ===");
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText);

// Render KaTeX after markdown is processed
// Note: Must call directly here because DOMContentLoaded has already fired
// when deferred scripts execute
console.log("=== Checking if livepreview_renderKatex is defined ===");
console.log("livepreview_renderKatex defined:", typeof livepreview_renderKatex !== "undefined");
if (typeof livepreview_renderKatex !== "undefined") {
	console.log("=== Calling livepreview_renderKatex() ===");
	livepreview_renderKatex();
	console.log("=== KaTeX render completed ===");
} else {
	console.error("ERROR: livepreview_renderKatex is not defined!");
}


