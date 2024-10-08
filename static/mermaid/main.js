function renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}
mermaid.initialize({ startOnLoad: false });
renderMermaid();

