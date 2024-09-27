import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11.2.1/+esm";
mermaid.initialize({ startOnLoad: false });
await mermaid.run({
    querySelector: '.language-mermaid',
});

