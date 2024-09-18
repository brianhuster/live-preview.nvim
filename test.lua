local utils = require('live-preview.utils')
local a = utils.sha1('dGhlIHNhbXBsZSBub25jZQ==258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
local c = vim.base64.encode(a)

print(a)
t(c)
