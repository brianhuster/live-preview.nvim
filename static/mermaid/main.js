import mermaid from "/live-preview.nvim/mermaid/mermaid.min.js";
mermaid.initialize({ startOnLoad: false });
await mermaid.run({
    querySelector: '.language-mermaid',
});

