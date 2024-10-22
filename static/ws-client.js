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
    console.log(message);

    if (message.type === "reload") {
      console.log("Reload message received");
      window.location.reload();
    } else if (message.type === "update") {
      content = message.content;

      // Check if the render function is defined before calling it
      if (typeof render !== "undefined") {
        render(content);
        if (typeof renderKatex !== "undefined") {
          renderKatex();
        }
        if (typeof renderMermaid !== "undefined") {
          renderMermaid();
        }
      } else {
        console.warn("Render function is not defined.");
      }
    } else if (message.type === "scroll") {
      console.log("Scroll message received");
      window.scrollTo(message.cursor[0], message.cursor[1]);
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
