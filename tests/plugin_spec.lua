local live_preview = require("live-preview")

describe("Live Preview", function()
	describe("setup", function()
		it("should be accessible", function()
			local status, err = pcall(function()
				live_preview.setup({
					commands = {
						start = "LivePreview",
						stop = "StopPreview"
					},
					port = 5500,
					browser = "default"
				})
			end)
			assert.is_true(status) -- Kiểm tra rằng hàm setup không gây lỗi
		end)
	end)
end)

describe("Server", function()
	local server = live_preview.server.Server:new("path/to/webroot")
	describe("new", function()
		it("should be accessible", function()
			assert.is_not_nil(server.server)
			assert.is_not_nil(server.webroot)
			assert.is_not_nil(server:new())
			assert.is_not_nil(server:stop())
			assert.is_not_nil(server:start())
			assert.is_not_nil(server:routes())
			assert.is_not_nil(server:watch_dir())
		end)
	end)
	describe("routes", function()
		it("should be equal to 'path/to/webroot/test'", function()
			assert.are.equal(server:routes("test"), "path/to/webroot/test")
		end)
	end)
end)
