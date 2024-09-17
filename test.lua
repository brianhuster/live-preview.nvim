-- body = require("live-preview.utils").sha1("Hello, World!")
-- print(body)

cmd = "echo hello\nworld"
obj1 = vim.system({ 'sh', '-c', cmd }, { text = true }):wait()
print(obj.stdout)
