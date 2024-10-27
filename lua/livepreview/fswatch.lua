---@brief Non-native file system watcher.
---
---This is made because |luv| (|vim.uv|) doesn't support recursive directory watching in other OSes than Windows and OSX
---
---To use this module, do:
---```lua
---local fswatch = require('livepreview.fswatch')
---```

local M = {}

local uv = vim.uv

---@class Watcher
---@field directory string
---@field watcher uv_fs_event_t
---@field children Watcher[]
---To call this class, do:
---```lua
---Watcher = require('livepreview.fswatch').Watcher
---```
local Watcher = {}
Watcher.__index = Watcher

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

---Create a new Watcher for a directory.
---@param directory string
---@return Watcher
function Watcher:new(directory)
	local o = {}
	setmetatable(o, self)
	o.__index = o
	o.directory = directory
	o.watcher = uv.new_fs_event()
	o.children = {}

	return o
end

---Start watching a directory and its subdirectories.
---@param callback function(filename: string, events: { change: boolean, rename: boolean })
function Watcher:start(callback)
	for _, subdir in ipairs(find_subdirs(self.directory)) do
		local fswatcher = Watcher:new(subdir)
		table.insert(self.children, fswatcher)
		fswatcher:start(callback)
	end
	self.watcher:start(self.directory, { recursive = false }, function(err, filename, events)
		if err then
			print("Error: ", err)
			return
		end
		if not uv.fs_stat(self.directory) or uv.fs_stat(self.directory).type ~= "directory" then
			self.watcher:close()
			self = nil
			return
		end
		if events.rename then
			if uv.fs_stat(filename).type == "directory" then
				local fswatcher = Watcher:new(filename)
				table.insert(self.children, fswatcher)
				fswatcher:start(callback)
			end
		end
		callback(filename, events)
	end)
end

---Close the watcher and all its children.
function Watcher:close()
	self.watcher:close()
	for _, child in ipairs(self.children) do
		child:close()
	end
end

M.Watcher = Watcher
return M
