function renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

mermaid.initialize({
	startOnLoad: false,
	securityLevel: 'loose',
	theme: 'neutral',
});


renderMermaid();

