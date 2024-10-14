L = require("livepreview")
local functions = { "L.health.check()", "L.health.is_compatible()", "L.preview_file()", "L.server.Server:new()", "L.server.Server:routes()", "L.server.Server:start()", "L.server.Server:stop()", "L.server.Server:watch_dir()", "L.server.handler.client()", "L.server.handler.request()", "L.server.handler.send_http_response()", "L.server.handler.serve_file()", "L.server.utils.content_type.get()", "L.server.utils.etag.generate()", "L.server.websocket.handshake()", "L.server.websocket.send()", "L.server.websocket.send_json()", "L.setup()", "L.stop_preview()", "L.utils.await_term_cmd()", "L.utils.get_path_lua_file()", "L.utils.get_plugin_path()", "L.utils.kill_port()", "L.utils.open_browser()", "L.utils.sha1()", "L.utils.supported_filetype()", "L.utils.term_cmd()", "L.utils.uv_read_file()", "L.utils.uv_write_file()" }
describe("Testing API functions", function()
	for _, func in ipairs(functions) do
		it("should be accessible " .. func, function()
			local status, err = pcall(function()
				local fn = load("return " .. func)
				assert(fn, "Function is not accessible: " .. func)
			end)

			assert(status, err or "unknown error")
		end)
	end
end)
