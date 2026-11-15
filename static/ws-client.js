const wsUrl = getWebSocketUrl();
let socket = new WebSocket(wsUrl);
let connected = true;

function getWebSocketUrl() {
	const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
	const hostname = window.location.hostname;
	const port = window.location.port ? `:${window.location.port}` : "";
	return `${protocol}//${hostname}${port}`;
}

/**
 * Normalize Windows file path to use forward slashes
 * @param {string} filepath - The file path to normalize
 * @returns {string} - The normalized file path
 */
const normalizePath = (filepath) => {
    if (!filepath) return '';

    const isWindows = /^[a-zA-Z]:\\/.test(filepath) ||
                      filepath.startsWith('\\\\');

    return isWindows ? filepath.replace(/\\/g, '/') : filepath;
};

/**
 * Check if browser should handle websocket message from server
 * @param {string} filepath - The path of the file
 * @returns {boolean} - True if the browser should handle the message, false otherwise
 */
const isRightPath = (filepath) => {
	const decodedPath = decodeURIComponent(window.location.pathname)
	console.log("Checking path:", filepath, "against", decodedPath);
    const normalized = normalizePath(filepath);
    return normalized.endsWith(decodedPath);
};

let livepreview_reload

// Session storage key that keeps the source view across reloads of the page
const sourceViewKey = `livepreview-source:${window.location.pathname}`;
// Latest source sent by Neovim: newer than the file on disk while the buffer is unsaved
let latestSource = null;
// <pre> that shows the source in place of the rendering, created on first use
let sourceView = null;

/**
 * Check if the page is rendered from its source in the browser (markdown, asciidoc, svg)
 * @returns {boolean}
 */
const hasSourceView = () =>
	typeof livepreview_render !== "undefined" || window.location.pathname.endsWith(".svg");

/** @returns {boolean} - True if the source is shown instead of the rendering */
const isSourceShown = () => sourceView !== null && sourceView.style.display !== "none";

/**
 * Keep the source view in step with the source the page renders
 * @param {string} content - The source of the file
 */
const updateSourceView = (content) => {
	latestSource = content;
	if (sourceView) {
		sourceView.textContent = content;
	}
};

/**
 * Show the source of the page in place of its rendering, or the rendering again
 * @param {boolean} show - True to show the source
 */
async function showSource(show) {
	const rendering = document.querySelector(".markdown-body");
	if (!rendering) {
		return;
	}
	if (show) {
		let source = latestSource;
		if (source === null) {
			// ?raw makes the server send the file as is
			const url = new URL(window.location.href);
			url.searchParams.set("raw", "");
			url.hash = "";
			try {
				const res = await fetch(url, { cache: "no-cache" });
				if (!res.ok) {
					return;
				}
				source = await res.text();
			} catch (error) {
				console.error("Fetching the source failed:", error);
				return;
			}
		}
		if (!sourceView) {
			sourceView = document.createElement("pre");
			sourceView.className = "livepreview-source";
			// The Markdown stylesheet sets the dark mode background on body, but the text
			// color only on .markdown-body: take it from the variable both are based on
			sourceView.style.cssText =
				"margin:0;padding:16px 32px;white-space:pre-wrap;overflow-wrap:anywhere;" +
				"color:var(--fgColor-default,inherit);" +
				"font:13px/1.5 ui-monospace,SFMono-Regular,Menlo,Consolas,monospace";
			rendering.after(sourceView);
		}
		// An update may have arrived during the fetch
		sourceView.textContent = latestSource ?? source;
		sessionStorage.setItem(sourceViewKey, "1");
	} else {
		sessionStorage.removeItem(sourceViewKey);
	}
	// Hidden content is left out of select all and copy
	rendering.style.display = show ? "none" : "";
	if (sourceView) {
		sourceView.style.display = show ? "" : "none";
	}
}

// "r" toggles between the rendering and the source, e.g. to copy the Markdown
document.addEventListener("keydown", (event) => {
	if (event.key !== "r" || event.ctrlKey || event.metaKey || event.altKey || event.repeat) {
		return;
	}
	const target = event.target;
	if (target.isContentEditable || ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)) {
		return;
	}
	if (!hasSourceView()) {
		return;
	}
	event.preventDefault();
	showSource(!isSourceShown());
});

window.addEventListener("load", () => {
	if (hasSourceView() && sessionStorage.getItem(sourceViewKey)) {
		showSource(true);
	}
});

async function connectWebSocket() {
	socket = new WebSocket(wsUrl);

	socket.onopen = () => {
		if (!connected) {
			window.location.reload();
		}
		connected = true;
		console.log("Connected to server");
		console.log("connected: ", connected);
		livepreview_reload = 0;
	};

	socket.onmessage = (event) => {
		const message = JSON.parse(event.data);

		if (message.type === "reload") {
			console.log("Reload message received");
			if (livepreview_reload === 0) {
				livepreview_reload = 1;
				connected = false;
				socket.close();
				return;
			}
		} else if (message.type === "update") {
			console.log("Update message received");
			let { filepath, content } = message;
			if (isRightPath(filepath)) {
				updateSourceView(content);
				// Check if the render function is defined before calling it
				if (typeof livepreview_render !== "undefined") {
					livepreview_render(content);
					if (typeof livepreview_renderKatex !== "undefined") {
						livepreview_renderKatex();
					}
					if (typeof livepreview_renderMermaid !== "undefined") {
						livepreview_renderMermaid();
					}
				} else {
					// Check if viewing svg
					if (window.location.pathname.endsWith(".svg")) {
						const livepreview_render = (text) => {
							document.querySelector('.markdown-body').innerHTML = text;
						}
						livepreview_render(content);
					}
					else {
						console.error("livepreview_render function is not defined");
					}
				}
			}
		} else if (message.type === "scroll") {
			console.log("Scroll message received");
			const { filepath, cursor } = message;
			if (isRightPath(filepath)) {
				const line = document.querySelector(`[data-source-line="${cursor[0]}"]`);
				if (line) {
					line.scrollIntoView({ behavior: "smooth", block: "center" });
				} else {
					// Find the closest line number
					const lineNumbers = document.querySelectorAll(".source-line");
					let closest = lineNumbers[0];
					let minDiff = Math.abs(cursor[0] - parseInt(closest.getAttribute("data-source-line")));
					lineNumbers.forEach((lineNumber) => {
						const diff = Math.abs(cursor[0] - parseInt(lineNumber.getAttribute("data-source-line")));
						if (diff < minDiff) {
							minDiff = diff;
							closest = lineNumber;
						}
					});
					closest.scrollIntoView({ behavior: "smooth", block: "center" });
				}
			}
		}
	};

	socket.onclose = () => {
		connected = false;
		console.log("Disconnected from server");
		window.location.reload();
	};

	socket.onerror = (error) => {
		console.error("WebSocket error:", error);
	};
}

window.onload = () => {
	connectWebSocket();
	setInterval(() => {
		if (!connected) {
			connectWebSocket();
		}
	}, 1000);
};

