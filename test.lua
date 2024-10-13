local function check_server(host, port)
	local tcp = vim.uv.new_tcp()

	tcp:connect(host, port, function(err)
		if err then
			print("Server is not running")
			tcp:close()
		else
			print("Server is running.")
			tcp:close()
		end
	end)
end

-- Gọi hàm kiểm tra server với địa chỉ host và port của bạn
check_server("127.0.0.1", 5500) -- Thay đổi host và port theo nhu cầu
