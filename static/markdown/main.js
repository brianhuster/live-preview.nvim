import { marked } from '/live-preview.nvim/static/markdown/marked.min.js';

class Lexer {
	constructor(options) {
		this.tokens = [];
		this.line = 1;
	}

	_token(src, top) {
		const token = { type: 'paragraph', text: src };

		token.lineNumber = this.line;

		const newlineCount = (src.match(/\n/g) || []).length;
		this.line += newlineCount;

		return token;
	}
}

const renderer = {
	code({ text, lang, escaped, token }) {
		console.log("token", token);
		const langString = (lang || '').match(/^\S*/)?.[0];
		const code = text.replace(/\n$/, '') + '\n';
		if (!langString) {
			return '<pre><code>' + code + '</code></pre>';
		}
		return `<pre data-source-line=${token.lineNumber} class="language-${langString}">${code}</pre>`
	},

	blockquote(token) {
		return `<blockquote data-source-line="${token.lineNumber}">${token.text}</blockquote>\n`;
	},

	// HTML hoặc tag
	html(token) {
		return `<div data-source-line="${token.lineNumber}">${token.text}</div>\n`;
	},

	// Heading
	heading(token) {
		return `<h${token.depth} data-source-line="${token.lineNumber}">${token.text}</h${token.depth}>\n`;
	},

	// Horizontal rule
	hr(token) {
		return `<hr data-source-line="${token.lineNumber}">\n`;
	},

	// List
	list(token) {
		return `<ul data-source-line="${token.lineNumber}">${token.items.map(item => this.listitem(item)).join('')}</ul>\n`;
	},

	// List item
	listitem(token) {
		return `<li data-source-line="${token.lineNumber}">${token.text}</li>\n`;
	},

	// Checkbox (for task lists)
	checkbox(token) {
		return `<input type="checkbox" ${token.checked ? 'checked' : ''} data-source-line="${token.lineNumber}">`;
	},

	// Paragraph
	paragraph(token) {
		return `<p data-source-line="${token.lineNumber}">${token.text}</p>\n`;
	},

	// Table
	table(token) {
		const header = token.header.map(cell => this.tablecell(cell)).join('');
		const body = token.rows.map(row => this.tablerow(row)).join('');
		return `<table data-source-line="${token.lineNumber}"><thead>${header}</thead><tbody>${body}</tbody></table>\n`;
	},

	// Table row
	tablerow(token) {
		return `<tr data-source-line="${token.lineNumber}">${token.cells.map(cell => this.tablecell(cell)).join('')}</tr>\n`;
	},

	// Table cell
	tablecell(token) {
		return `<td data-source-line="${token.lineNumber}">${token.text}</td>\n`;
	},

	strong(token) {
		return `<strong data-source-line="${token.lineNumber}">${token.text}</strong>`;
	},

	// Emphasis (italic)
	em(token) {
		return `<em data-source-line="${token.lineNumber}">${token.text}</em>`;
	},

	// Inline code
	codespan(token) {
		return `<code data-source-line="${token.lineNumber}">${token.text}</code>`;
	},

	// Line break
	br(token) {
		return `<br data-source-line="${token.lineNumber}">`;
	},

	// Strikethrough (delete)
	del(token) {
		return `<del data-source-line="${token.lineNumber}">${token.text}</del>`;
	},

	// Hyperlink
	link(token) {
		return `<a href="${token.href}" data-source-line="${token.lineNumber}">${token.text}</a>`;
	},

	// Image
	image(token) {
		return `<img src="${token.href}" alt="${token.text}" data-source-line="${token.lineNumber}">`;
	},

	// Text or escape sequences
	text(token) {
		return `<span data-source-line="${token.lineNumber}">${token.text}</span>`;
	},
};

marked.use({ renderer });

const markdownText = document.querySelector('.markdown-body').innerHTML;
const html = marked.parse(markdownText);
console.log(html);
document.querySelector('.markdown-body').innerHTML = html;

