// Simple markdown-it plugin for KaTeX math rendering
// Based on vscode-markdown-it-katex approach

(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
    typeof define === 'function' && define.amd ? define(factory) :
    (global = global || self, global.markdownitKatex = factory());
}(this, function () { 'use strict';

    function math_inline(state, silent) {
        if (state.src[state.pos] !== "$") {
            return false;
        }

        // Check if it's a valid opening delimiter
        const prevChar = state.src[state.pos - 1];
        const nextChar = state.src[state.pos + 1];
        
        if (prevChar && !/\s/.test(prevChar) && /[\w\d]/.test(prevChar)) {
            return false;  // Not a valid opening
        }

        // Find closing delimiter
        let start = state.pos + 1;
        let match = start;
        
        while ((match = state.src.indexOf("$", match)) !== -1) {
            // Check for escaped $
            let pos = match - 1;
            while (state.src[pos] === "\\") {
                pos -= 1;
            }
            
            // Even number of escapes means it's a real closing delimiter
            if (((match - pos) % 2) == 1) {
                break;
            }
            match += 1;
        }

        if (match === -1) {
            return false;
        }

        // Check if it's a valid closing delimiter
        const afterMatch = state.src[match + 1];
        if (afterMatch && /[\w\d]/.test(afterMatch)) {
            return false;
        }

        if (!silent) {
            const token = state.push('math_inline', 'math', 0);
            token.markup = "$";
            token.content = state.src.slice(start, match);
        }

        state.pos = match + 1;
        return true;
    }

    function math_block(state, start, end, silent) {
        let pos = state.bMarks[start] + state.tShift[start];
        let max = state.eMarks[start];

        if (pos + 2 > max) {
            return false;
        }
        
        if (state.src.slice(pos, pos + 2) !== '$$') {
            return false;
        }

        pos += 2;
        let firstLine = state.src.slice(pos, max);

        // Check for single line $$...$$
        if (firstLine.trim().endsWith('$$') && firstLine.indexOf('$$') === firstLine.length - 2) {
            firstLine = firstLine.trim().slice(0, -2);
            
            if (!silent) {
                const token = state.push('math_block', 'math', 0);
                token.block = true;
                token.content = firstLine;
                token.markup = '$$';
            }
            
            state.line = start + 1;
            return true;
        }

        // Multi-line block
        let next = start;
        let lastLine = '';
        let found = false;

        for (next = start + 1; !found && next < end; next++) {
            pos = state.bMarks[next] + state.tShift[next];
            max = state.eMarks[next];

            const line = state.src.slice(pos, max);
            
            if (line.trim().endsWith('$$')) {
                lastLine = line.trim().slice(0, -2);
                found = true;
            }
        }

        if (!found) {
            return false;
        }

        if (!silent) {
            const token = state.push('math_block', 'math', 0);
            token.block = true;
            token.content = (firstLine ? firstLine + '\n' : '') +
                           state.getLines(start + 1, next - 1, state.tShift[start], true) +
                           (lastLine ? lastLine : '');
            token.markup = '$$';
            token.map = [start, state.line];
        }

        state.line = next;
        return true;
    }

    return function markdown_it_katex(md, options) {
        options = options || {};

        // Add parsing rules
        md.inline.ruler.after('escape', 'math_inline', math_inline);
        md.block.ruler.after('blockquote', 'math_block', math_block, {
            alt: ['paragraph', 'reference', 'blockquote', 'list']
        });

        // Add renderers
        md.renderer.rules.math_inline = function (tokens, idx) {
            const content = tokens[idx].content;
            try {
                return katex.renderToString(content, {
                    throwOnError: false,
                    displayMode: false
                });
            } catch (error) {
                return `<span class="katex-error">${content}</span>`;
            }
        };

        md.renderer.rules.math_block = function (tokens, idx) {
            const content = tokens[idx].content;
            try {
                return katex.renderToString(content, {
                    throwOnError: false,
                    displayMode: true
                });
            } catch (error) {
                return `<div class="katex-error">${content}</div>`;
            }
        };
    };

}));