function livepreview_renderKatex() {
	renderMathInElement(document.body, {
		delimiters: [
			{ left: '$$', right: '$$', display: true },
			{ left: '$', right: '$', display: false },
			{ left: '\\(', right: '\\)', display: false },
			{ left: '\\[', right: '\\]', display: true }
		],
		throwOnError: false
	});
}

// Note: This function is called from markdown/main.js after rendering
// DOMContentLoaded event has already fired before deferred scripts execute
