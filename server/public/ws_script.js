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
        console.log("Connected to server");
        console.log("connected: ", connected);
    };

    socket.onclose = () => {
        connected = false;
        console.log("Disconnected from server");
        console.log("connected: ", connected);
    };

    socket.onerror = (error) => {
        connected = false;
        console.error("WebSocket error:", error);
        console.log("connected: ", connected);
    };
}

function main() {
    connectWebSocket();
    setInterval(() => {
        if (!connected) {
            connectWebSocket();
        }
    }, 100);
}

window.onload = main;


