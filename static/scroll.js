// The MIT License (MIT)
//
// Copyright (c) 2022 年糕小豆汤 <ooiss@qq.com>
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

function scroll(offsetTop) {
	[document.body, document.documentElement].forEach((ele) => {
		// eslint-disable-next-line
		TweenLite.to(
			ele,
			0.4,
			{
				scrollTop: offsetTop,
				ease: Power2.easeOut // eslint-disable-line
			}
		)
	})
}

function getAttrTag(line) {
	return `[data-source-line="${line}"]`
}

function getPreLineOffsetTop(line) {
	let currentLine = line - 1
	let ele = null
	while (currentLine > 0 && !ele) {
		ele = document.querySelector(getAttrTag(currentLine))
		if (!ele) {
			currentLine -= 1
		}
	}
	return [
		currentLine >= 0 ? currentLine : 0,
		ele ? ele.offsetTop : 0
	]
}

function getNextLineOffsetTop(line, len) {
	let currentLine = line + 1
	let ele = null
	while (currentLine < len && !ele) {
		ele = document.querySelector(getAttrTag(currentLine))
		if (!ele) {
			currentLine += 1
		}
	}
	return [
		currentLine < len ? currentLine : len - 1,
		ele ? ele.offsetTop : document.documentElement.scrollHeight
	]
}

function topOrBottom(line, len) {
	if (line === 0) {
		scroll(0)
	} else if (line === len - 1) {
		scroll(document.documentElement.scrollHeight)
	}
}

function relativeScroll(line, ratio, len) {
	let offsetTop = 0
	const lineEle = document.querySelector(`[data-source-line="${line}"]`)
	if (lineEle) {
		offsetTop = lineEle.offsetTop
	} else {
		const pre = getPreLineOffsetTop(line)
		const next = getNextLineOffsetTop(line, len)
		offsetTop = pre[1] + ((next[1] - pre[1]) * (line - pre[0]) / (next[0] - pre[0]))
	}
	scroll(offsetTop - document.documentElement.clientHeight * ratio)
}

scrollToLine = {
	relative: function({
		cursor,
		winline,
		winheight,
		len
	}) {
		const line = cursor - 1
		const ratio = winline / winheight
		if (line === 0 || line === len - 1) {
			topOrBottom(line, len)
		} else {
			relativeScroll(line, ratio, len)
		}
	},
	middle: function({
		cursor,
		// winline,
		// winheight,
		len
	}) {
		const line = cursor - 1
		if (line === 0 || line === len - 1) {
			topOrBottom(line, len)
		} else {
			relativeScroll(line, 0.5, len)
		}
	},
	top: function({
		cursor,
		winline,
		// winheight,
		len
	}) {
		let line = cursor - 1
		if (line === 0 || line === len - 1) {
			topOrBottom(line, len)
		} else {
			line = cursor - winline
			relativeScroll(line, 0, len)
		}
	}
}
