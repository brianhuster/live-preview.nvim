const wsUrl = getWebSocketUrl();
let socket = new WebSocket(wsUrl);
let connected = true;

function getWebSocketUrl() {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const hostname = window.location.hostname;
    const port = window.location.port ? `:${window.location.port}` : "";
    return `${protocol}//${hostname}${port}`;
}

function connectWebSocket() {
    socket = new WebSocket(wsUrl);

    socket.onopen = () => {
        console.log("Connected to server");
        connected = true;
    };

    socket.onclose = () => {
        console.log("Disconnected from server");
        connected = false;
        return;
    };

    socket.onerror = (error) => {
        console.error("WebSocket error:", error);
    };
}

window.onload = connectWebSocket;

while (true) {
    if (!connected) {
        connectWebSocket();
    }
    sleep(100);
}
