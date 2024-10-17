// MIT License
//
// Copyright (c) 2017 Brett Walker
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
function injectLinenumbersPlugin(md) {
	//
	// Inject line numbers for sync scroll. Notes:
	//
	// - We track only headings and paragraphs, at any level.
	// - TODO Footnotes content causes jumps. Level limit filters it automatically.
	function injectLineNumbers(tokens, idx, options, env, slf) {
		var line
		// if (tokens[idx].map && tokens[idx].level === 0) {
		if (tokens[idx].map) {
			line = tokens[idx].map[0]
			tokens[idx].attrJoin('class', 'source-line')
			tokens[idx].attrSet('data-source-line', String(line))
		}
		return slf.renderToken(tokens, idx, options, env, slf)
	}

	md.renderer.rules.paragraph_open = injectLineNumbers
	md.renderer.rules.heading_open = injectLineNumbers
	md.renderer.rules.list_item_open = injectLineNumbers
	md.renderer.rules.table_open = injectLineNumbers
}

