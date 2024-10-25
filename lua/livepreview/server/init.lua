---@brief Server module for live-preview.nvim
---To require this module, do
---```lua
---local server = require('livepreview.server')
---```

local M = {}
M.handler = require("livepreview.server.handler")
M.utils = require("livepreview.server.utils")
M.Server = require("livepreview.server.Server")
M.websocket = require("livepreview.server.websocket")
return M
