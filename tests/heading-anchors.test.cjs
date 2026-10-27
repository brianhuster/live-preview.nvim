const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const root = path.resolve(__dirname, "..");
const body = { textContent: "", innerHTML: "" };

const sandbox = {
	console,
	document: {
		compatMode: "CSS1Compat",
		querySelector: () => body,
	},
	hljs: { getLanguage: () => false, highlightAll: () => {} },
};

sandbox.window = sandbox;
sandbox.self = sandbox;

const context = vm.createContext(sandbox);

// Load the same JavaScript libraries as the browser preview.
for (const file of [
	"static/katex/katex.min.js",
	"static/markdown/markdown-it.min.js",
	"static/markdown/markdown-it-emoji.min.js",
	"static/markdown/markdown-it-katex.js",
	"static/markdown/line-numbers.js",
	"static/markdown/main.js",
]) {
	const code = fs.readFileSync(path.join(root, file), "utf8");
	vm.runInContext(code, context, { filename: file });
}

const md = vm.runInContext("md", context);

const headingIds = (markdown) =>
	[...md.render(markdown).matchAll(/<h[1-6]\b[^>]*\bid="([^"]*)"/g)]
		.map((match) => match[1]);

const cases = [
	["Basic heading", "## Introduction", ["introduction"]],
	["Punctuation", "## What is SQL?", ["what-is-sql"]],
	["Finnish characters", "## Käyttöohjeet", ["käyttöohjeet"]],
	["Duplicate headings", "## Intro\n## Intro", ["intro", "intro-1"]],
	["ID collisions", "## Intro\n## Intro-1\n## Intro", ["intro", "intro-1", "intro-2"]],
	["Bold text", "## **Important** information", ["important-information"]],
	["Inline code", "## Using `SELECT`", ["using-select"]],
	["Links", "## [API documentation](https://example.com)", ["api-documentation"]],
	["Italic text", "## *Getting started* today", ["getting-started-today"]],
	["Setext headings", "Introduction\n============", ["introduction"]],
	["All heading levels", "# A\n## B\n### C\n#### D\n##### E\n###### F", ["a", "b", "c", "d", "e", "f"]],
	["Ignore fenced code", "```md\n## Fake\n```\n## Real", ["real"]],
	["Punctuation-only headings", "## ???\n## ???", ["section", "section-1"]],
];

for (const [name, markdown, expected] of cases) {
	test(name, () => assert.deepEqual(headingIds(markdown), expected));
}

test("Re-rendering keeps stable IDs", () => {
	const markdown = "## Introduction\n## Introduction";
	assert.deepEqual(headingIds(markdown), headingIds(markdown));
});

test("Existing source-line attributes are preserved", () => {
	const html = md.render("## Introduction");
	assert.match(html, /<h2\b[^>]*\bclass="source-line"/);
	assert.match(html, /<h2\b[^>]*\bdata-source-line="0"/);
});

