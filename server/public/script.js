const wsUrl = getWebSocketUrl(); 
let socket = new WebSocket(wsUrl);

function getWebSocketUrl() {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  const hostname = window.location.hostname;
  const port = window.location.port ? `:${window.location.port}` : '';
  return `${protocol}//${hostname}${port}`;
}

function connectWebSocket() {
  socket = new WebSocket(wsUrl);

  socket.onopen = () => {
    console.log("Connected to server");
       };

  socket.onclose = () => {
    console.log("Disconnected from server"); 

    setTimeout(() => {
        window.location.reload();
        connectWebSocket(); 
    }, 1000);
  };

  socket.onerror = (error) => {
    console.error("WebSocket error:", error);
  };
}

window.onload = connectWebSocket;


