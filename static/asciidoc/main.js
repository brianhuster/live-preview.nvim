const asciidoctor = Asciidoctor();

function livepreview_render(adoc) {
	const html = asciidoctor.convert(adoc);
	console.log(html);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const adoc = document.querySelector('.markdown-body').innerHTML;
livepreview_render(adoc);
