const config = window.__livepreview_mermaid_config || { renderer: 'default', theme: 'default' };

function livepreview_renderMermaid() {
	if (config.renderer === 'beautiful') {
		livepreview_renderBeautifulMermaid();
	} else {
		livepreview_renderDefaultMermaid();
	}
}

function livepreview_renderDefaultMermaid() {
	const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

	mermaid.initialize({
		startOnLoad: false,
		securityLevel: 'loose',
		theme: prefersDark ? 'dark' : 'default',
	});

	mermaid.run({
		querySelector: '.language-mermaid',
	});
}

function livepreview_renderBeautifulMermaid() {
	const blocks = document.querySelectorAll('.language-mermaid');

	blocks.forEach(function(block) {
		const code = block.textContent;
		const pre = block.closest('pre');

		try {
			const theme = beautifulMermaid.THEMES[config.theme] || beautifulMermaid.THEMES['github-light'];
			const svg = beautifulMermaid.renderMermaidSVG(code, { ...theme, transparent: true });
			if (pre) {
				pre.outerHTML = svg;
			} else {
				block.innerHTML = svg;
			}
		} catch (e) {
			block.innerHTML = '<pre class="language-mermaid" style="color: red;">Error rendering diagram: ' + e.message + '</pre>';
		}
	});
}

if (config.renderer === 'beautiful') {
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', livepreview_renderMermaid);
	} else {
		livepreview_renderMermaid();
	}
} else {
	const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

	mermaid.initialize({
		startOnLoad: false,
		securityLevel: 'loose',
		theme: prefersDark ? 'dark' : 'default',
	});

	window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
		mermaid.initialize({
			startOnLoad: false,
			securityLevel: 'loose',
			theme: e.matches ? 'dark' : 'default',
		});
		livepreview_renderMermaid();
	});

	livepreview_renderMermaid();
}
