-- main.lua
local livepreview_config = require('livepreview.config')

-- Sửa đổi giá trị port
livepreview_config = { name = 'new name' }

-- In ra thông tin của bảng config
vim.print(require('livepreview.config'))
