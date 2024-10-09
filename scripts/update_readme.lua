#!/usr/bin/env -S nvim -l
local uv = vim.uv
local read_file_sync = require("livepreview").utils.uv_read_file
local write_file_sync = require("livepreview").utils.uv_write_file

local packspec = vim.fn.json_decode(read_file_sync('pkg.json'))

local function update_readme(file)
	local readme = read_file_sync(file)
	local lines = vim.split(readme, '\n')
	local updated_lines = {}

	for _, line in ipairs(lines) do
		if line:match("^# .*$") then
			line = "# " .. packspec.name
		end

		if line:match("^- Neovim.*$") then
			line = "- Neovim " .. packspec.engines.nvim
		end

		table.insert(updated_lines, line)
	end

	local updated_readme = table.concat(updated_lines, "\n")
	write_file_sync(file, updated_readme)
	print(file .. ' has been updated based on pkg.json')
end

local function readdir_sync(path)
	local req = uv.fs_scandir(path)
	local files = {}
	while true do
		local name, typ = uv.fs_scandir_next(req)
		if not name then break end
		table.insert(files, name)
	end
	return files
end

local files = readdir_sync('.')

local readme_files = {}
for _, file in ipairs(files) do
	if file == 'README.md' or file:match('^README%..*%.md$') then
		table.insert(readme_files, file)
	end
end

for _, file in ipairs(readme_files) do
	update_readme(file)
end
