const wsUrl=getWebSocketUrl();let socket=new WebSocket(wsUrl),connected=!0;function getWebSocketUrl(){return`${"https:"===window.location.protocol?"wss:":"ws:"}//${window.location.hostname}${window.location.port?`:${window.location.port}`:""}`}async function connectWebSocket(){socket=new WebSocket(wsUrl),socket.onopen=()=>{connected||window.location.reload(),console.log("Connected to server"),console.log("connected: ",connected)},socket.onmessage=o=>{"reload"===o.data&&(console.log("Reload message received"),window.location.reload())},socket.onclose=()=>{connected=!1,console.log("Disconnected from server"),console.log("connected: ",connected)},socket.onerror=o=>{connected=!1,console.error("WebSocket error:",o),console.log("connected: ",connected)}}window.onload=()=>{connectWebSocket(),setInterval((()=>{connected||connectWebSocket()}),1e3)};