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
		if (event.data === "reload") {
			console.log("Reload message received");
			window.location.reload();
		}
		else {
			console.log("Message received: ", event.data);
			const message = JSON.parse(event.data);
			if (message.type === "scroll") {
				const line = message.line;
				console.log("line: ", line);
				const filepath = message.filepath;
				console.log("filepath: ", filepath);
				const currentPath = window.location.pathname;
				console.log("currentPath: ", currentPath);
				if (currentPath.includes(filepath)) {
					const targetElement = document.querySelector(`[data-line-number="${line}"]`);
					if (targetElement) {
						const elementPosition = targetElement.getBoundingClientRect().top + window.scrollY;
						console.log("Scrolling to line: ", line);
						window.scrollTo({ top: elementPosition, behavior: 'smooth' });
					}
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

