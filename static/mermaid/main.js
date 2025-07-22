function livepreview_renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

mermaid.initialize({
	startOnLoad: false,
	securityLevel: 'loose',
	theme: 'neutral',
});


livepreview_renderMermaid();

