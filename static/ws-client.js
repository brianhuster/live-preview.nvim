const wsUrl = getWebSocketUrl();
let socket = new WebSocket(wsUrl);
let connected = true;

function getWebSocketUrl() {
	const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
	const hostname = window.location.hostname;
	const port = window.location.port ? `:${window.location.port}` : "";
	return `${protocol}//${hostname}${port}`;
}

async function connectWebSocket() {
	socket = new WebSocket(wsUrl);

	socket.onopen = () => {
		if (!connected) {
			window.location.reload();
		}
		connected = true;
		console.log("Connected to server");
		console.log("connected: ", connected);
	};

	socket.onmessage = (event) => {
		const message = JSON.parse(event.data);

		if (message.type === "reload") {
			console.log("Reload message received");
			window.location.reload();
		} else if (message.type = "update") {
			content = message.content;
			if (render) {
				render(content);
				renderKatex();
				renderMermaid();
			}
		}
		else if (message.type = "scroll") {
			console.log("Scroll message received");
			scrollToLine.middle({
				cursor: message.cursor[1],
				len: message.len
			})
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

