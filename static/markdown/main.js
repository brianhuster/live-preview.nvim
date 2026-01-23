const md = window.markdownit({
	html: true,
	highlight: function(str, lang) {
		if (lang && hljs.getLanguage(lang)) {
			try {
				return hljs.highlight(str, { language: lang }).value;
			} catch (__) { }
		}

		return ''; // use external default escaping
	}
});

function math_block(state, startLine, endLine, silent) {
  var firstLine, lastLine, lastPos, found = false,
      pos = state.bMarks[startLine] + state.tShift[startLine],
      max = state.eMarks[startLine];

  if (pos + 2 > max) { return false; }
  if (state.src.slice(pos, pos + 2) !== '$$') { return false; }

  pos += 2;
  firstLine = state.src.slice(pos, max);

  if (silent) { return true; }
  if (firstLine.trim().slice(-2) === '$$') {
    // Single line expression
    firstLine = firstLine.trim().slice(0, -2);
    found = true;
  }

  for (var nextLine = startLine; !found; ) {

    nextLine++;

    if (nextLine >= endLine) { break; }

    pos = state.bMarks[nextLine] + state.tShift[nextLine];
    max = state.eMarks[nextLine];

    if (pos < max && state.tShift[nextLine] < state.blkIndent) {
      // non-empty line with negative indent should stop the list:
      break;
    }

    if (state.src.slice(pos, max).trim().indexOf('$$') !== -1) {
      lastPos = state.src.slice(0, max).lastIndexOf('$$');
      lastLine = state.src.slice(pos, lastPos);
      found = true;
    }
  }

  state.line = nextLine + 1;

  var token = state.push('math_block', 'math', 0);
  token.block = true;
  if (firstLine.trim().slice(-2) === '$$') {
    token.content = firstLine;
  } else {
    token.content = state.getLines(startLine, nextLine + 1, state.tShift[startLine], true)
      .replace(/^\s*\$\$\s*|\s*\$\$\s*$/g, '');
  }
  token.map = [ startLine, state.line ];
  token.markup = '$$';
  return true;
}

md.block.ruler.before('fence', 'math_block', math_block, {
    alt: [ 'paragraph', 'reference', 'blockquote', 'list' ]
});

md.renderer.rules.math_block = (tokens, idx) => {
    return '$$' + tokens[idx].content + '$$';
};

md.use(livepreview_injectLinenumbersPlugin);

md.use(markdownitEmoji);

md.use(window.markdownitGithubAlerts);

const livepreview_render = (text) => {
	const html = md.render(text);
	console.log(html);
	document.querySelector('.markdown-body').innerHTML = html;
	hljs.highlightAll();
}

const markdownText = document.querySelector('.markdown-body').textContent;
livepreview_render(markdownText);
