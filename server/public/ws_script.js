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
        connected = true;
        console.log("Connected to server");
    };

    socket.onclose = () => {
        connected = false;
        console.log("Disconnected from server");
    };

    socket.onerror = (error) => {
        connected = false;
        console.error("WebSocket error:", error);
    };
}

window.onload = () => {
    connectWebSocket();
    setInterval(() => {
        if (!connected) {
            connectWebSocket();
            if (connected) {
                window.location.reload();
            }
        }
    }, 1);
}


