---@brief Non-native file system watcher.
---To use this module, do:
---```lua
---local fswatch = require('livepreview.fswatch')
---```

local uv = vim.uv

---@class FSWatcher
---@field directory string
---@field callback function
---To call this class, do:
---```lua
---FSWatcher = require('livepreview.fswatch').FSWatcher
---```
local FSWatcher = {}
FSWatcher.__index = FSWatcher

--- Find all subdirectories of a directory.
--- @param dir string
local function find_subdirs(dir)
	local subdirs = {}
	local req = uv.fs_scandir(dir)
	if not req then return subdirs end

	while true do
		local name, type = uv.fs_scandir_next(req)
		if not name then break end
		local full_path = dir .. '/' .. name
		if type == 'directory' then
			table.insert(subdirs, FSWatcher:new(full_path, callback))
		end
	end
	return subdirs
end

---Create a new FSWatcher for a directory.
---@param directory string
---@param callback function(filename: string, events: string)
---The callback function to be called when a file changes.
---The `filename` parameter is the name of the file that changed.
---@return FSWatcher
function FSWatcher:new(directory, callback)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.directory = directory
	o.callback = callback
	o.watcher = uv.new_fs_event()
	o.chidren = {}
	for _, subdir in ipairs(find_subdirs(directory)) do
		local fswatcher = FSWatcher:new(subdir, callback)
		table.insert(o.children, fswatcher)
	end
	o.watcher:start(directory, {}, function(err, filename, events)
		if err then
			print("Error: ", err)
			return
		end
		o.callback(filename, events)
	end)

	return o
end

return {
	FSWatcher = FSWatcher
}
