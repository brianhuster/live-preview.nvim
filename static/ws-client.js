const wsUrl = getWebSocketUrl();
let socket = new WebSocket(wsUrl);
let connected = true;

function getWebSocketUrl() {
	const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
	const hostname = window.location.hostname;
	const port = window.location.port ? `:${window.location.port}` : "";
	return `${protocol}//${hostname}${port}`;
}

let livepreview_reload

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
				window.location.reload();
				livepreview_reload = 1;
			}
		} else if (message.type === "update") {
			console.log("Update message received");
			content = message.content;

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
				console.warn("Render function is not defined.");
			}
		} else if (message.type === "scroll") {
			console.log("Scroll message received");
			const { filepath, cursor } = message;
			if (filepath.includes(window.location.pathname)) {
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

