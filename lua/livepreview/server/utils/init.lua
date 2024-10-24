---@brief 'livepreview.server.utils' module
---To require this module, do
---```lua
---utils = require('livepreview.server.utils')
---```
local M = {}
M.etag = require('livepreview.server.utils.etag')
M.content_type = require('livepreview.server.utils.content_type')

return M
