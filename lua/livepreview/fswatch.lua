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

--- Find all first level subdirectories of a directory.
--- @param dir string
--- @return table<string>
local function find_subdirs(dir)
	local subdirs = {}
	local fd = uv.fs_scandir(dir)
	if not fd then
		return subdirs
	end
	while true do
		local name, t = uv.fs_scandir_next(fd)
		if not name then
			break
		end
		if t == "directory" then
			table.insert(subdirs, dir .. "/" .. name)
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
	for _, subdir in ipairs(find_subdirs(o.directory)) do
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
