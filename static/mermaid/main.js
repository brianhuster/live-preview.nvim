function livepreview_renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

mermaid.initialize({
	startOnLoad: false,
	securityLevel: 'loose',
	theme: prefersDark ? 'dark' : 'default',
});

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
	mermaid.initialize({
		startOnLoad: false,
		securityLevel: 'loose',
		theme: e.matches ? 'dark' : 'default',
	});
	livepreview_renderMermaid();
});

livepreview_renderMermaid();
