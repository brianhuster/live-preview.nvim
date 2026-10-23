const wsUrl = getWebSocketUrl();
let socket = null;
// Whether the socket has opened at least once since the page loaded
let everConnected = false;
// Whether the socket dropped, so updates may have been missed
let disconnected = false;
// ETag of the previewed file when the page last matched it on disk
let sourceEtag = null;
// An update from Neovim is newer than the file on disk, so it wins over a resync
let updatedSinceReconnect = false;

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

/**
 * Check if the page renders its source in the browser (markdown, asciidoc, svg),
 * so it can be updated in place rather than reloaded
 * @returns {boolean}
 */
const isRenderedPage = () =>
	typeof livepreview_render !== "undefined" || window.location.pathname.endsWith(".svg");

/**
 * Render the source of the previewed file into the page
 * @param {string} content - The source of the file
 */
const renderContent = (content) => {
	// Check if the render function is defined before calling it
	if (typeof livepreview_render !== "undefined") {
		livepreview_render(content);
		if (typeof livepreview_renderKatex !== "undefined") {
			livepreview_renderKatex();
		}
		if (typeof livepreview_renderMermaid !== "undefined") {
			livepreview_renderMermaid();
		}
	} else if (window.location.pathname.endsWith(".svg")) {
		// Check if viewing svg
		document.querySelector('.markdown-body').innerHTML = content;
	} else {
		console.error("livepreview_render function is not defined");
	}
};

/**
 * Fetch the previewed file. Without text/html in Accept, the server sends its
 * source as is rather than wrapped in a page.
 * @returns {Promise<Response>}
 */
const fetchSource = () =>
	fetch(window.location.href, { cache: "no-store", headers: { Accept: "*/*" } });

async function recordEtag() {
	try {
		const res = await fetchSource();
		if (res.ok) {
			sourceEtag = res.headers.get("ETag");
		}
	} catch (error) {
		console.error("Could not fetch the ETag:", error);
	}
}

/**
 * Bring the page up to date after a reconnect. Reloading would lose the scroll
 * position, and browsers drop the socket whenever a background tab is frozen.
 */
async function resync() {
	if (!isRenderedPage()) {
		// HTML pages can't be patched in place, and their CSS or JS may have changed too
		window.location.reload();
		return;
	}
	try {
		const res = await fetchSource();
		const etag = res.headers.get("ETag");
		if (!res.ok || etag === sourceEtag) {
			return;
		}
		const content = await res.text();
		if (updatedSinceReconnect) {
			return;
		}
		sourceEtag = etag;
		console.log("File changed while disconnected, rendering it again");
		renderContent(content);
	} catch (error) {
		console.error("Resync failed:", error);
	}
}

function connectWebSocket() {
	socket = new WebSocket(wsUrl);

	socket.onopen = () => {
		console.log("Connected to server");
		if (!everConnected) {
			everConnected = true;
			recordEtag();
		} else if (disconnected) {
			updatedSinceReconnect = false;
			resync();
		}
		disconnected = false;
	};

	socket.onmessage = (event) => {
		const message = JSON.parse(event.data);

		if (message.type === "reload") {
			console.log("Reload message received");
			window.location.reload();
		} else if (message.type === "update") {
			console.log("Update message received");
			let { filepath, content } = message;
			if (isRightPath(filepath)) {
				updatedSinceReconnect = true;
				renderContent(content);
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
		console.log("Disconnected from server");
		disconnected = true;
	};

	socket.onerror = (error) => {
		console.error("WebSocket error:", error);
	};
}

function reconnect() {
	// Leave a socket that is still connecting or closing alone
	if (socket && socket.readyState !== WebSocket.CLOSED) {
		return;
	}
	connectWebSocket();
}

window.onload = () => {
	connectWebSocket();
	setInterval(reconnect, 1000);
	// Timers barely run in a background tab, so don't wait for one on return
	document.addEventListener("visibilitychange", () => {
		if (document.visibilityState === "visible") {
			reconnect();
		}
	});
};
