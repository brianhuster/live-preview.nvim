function livepreview_renderKatex() {
	const macros = (window.LIVE_PREVIEW_KATEX_MACROS && typeof window.LIVE_PREVIEW_KATEX_MACROS === "object")
		? window.LIVE_PREVIEW_KATEX_MACROS
		: {};

	renderMathInElement(document.body, {
		delimiters: [
			{ left: '$$', right: '$$', display: true },
			{ left: '$', right: '$', display: false },
			{ left: '\\(', right: '\\)', display: false },
			{ left: '\\[', right: '\\]', display: true }
		],
		throwOnError: false,
		macros
	});
}

document.addEventListener("DOMContentLoaded", function() {
	livepreview_renderKatex();
});
