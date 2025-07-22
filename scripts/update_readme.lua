#!/usr/bin/env -S nvim -l
local uv = vim.uv
local read_file_sync = require("livepreview.utils").read_file

local packspec = vim.json.decode(read_file_sync("pkg.json"))

local function write_file_sync(file, content)
	local f = io.open(file, "w")
	if not f then
		return false
	end
	f:write(content)
	f:close()
	return true
end

local function update_readme(file)
	local readme = read_file_sync(file)
	local lines = vim.split(readme, "\n")
	local updated_lines = {}

	for _, line in ipairs(lines) do
		if line:match("^- Neovim.*$") then
			line = "- Neovim " .. packspec.engines.nvim
		end

		table.insert(updated_lines, line)
	end

	local updated_readme = table.concat(updated_lines, "\n")
	write_file_sync(file, updated_readme)
	print(file .. " has been updated based on pkg.json")
end

local function update_doc(file)
	local doc = read_file_sync(file)
	if not doc then
		return
	end
	local updated_doc = doc:gsub(
		"%*livepreview%.txt%*%s+For Nvim [0-9%.]+",
		"*livepreview.txt*             For Nvim " .. packspec.engines.nvim
	)
	write_file_sync(file, updated_doc)
	print(file .. " has been updated based on pkg.json")
end

local function readdir_sync(path)
	local fn = vim.fn
	path = fn.fnamemodify(path, ":p")
	return vim.split(fn.glob(path .. "/**"), "\n")
end

local files = readdir_sync(".")

for _, file in ipairs(files) do
	if file:match("README%.md") or file:match("^README%..*%.md$") then
		update_readme(file)
	elseif file:match("doc/livepreview.txt") then
		update_doc(file)
	end
end
