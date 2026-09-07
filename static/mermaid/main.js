function livepreview_renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

mermaid.initialize({
	startOnLoad: false,
	securityLevel: 'loose',
	look: 'neo',
	theme: prefersDark ? 'neo-dark' : 'neo',
});

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
	mermaid.initialize({
		startOnLoad: false,
		securityLevel: 'loose',
		look: 'neo',
		theme: e.matches ? 'neo-dark' : 'neo',
	});
	livepreview_renderMermaid();
});

livepreview_renderMermaid();
