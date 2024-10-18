function renderMermaid() {
	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');

function handleColorSchemeChange(event) {
	if (event.matches) {
		mermaid.initialize({
			startOnLoad: false,
			securityLevel: 'loose',
			theme: 'dark',
		});
	} else {
		mermaid.initialize({
			startOnLoad: false,
			securityLevel: 'loose',
			theme: 'default',
		});
	}
}

renderMermaid();
mediaQueryList.addListener(handleColorSchemeChange);

