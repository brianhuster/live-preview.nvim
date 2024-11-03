local M = {}

function M.livepreview()
	require("livepreview.picker").telescope()
end

return require("telescope").register_extension({
	setup = function() end,
	exports = M,
})
