#!/usr/bin/env -S nvim -l
local uv = vim.loop

local function read_file_sync(path)
    local fd = assert(uv.fs_open(path, "r", 438))
    local stat = assert(uv.fs_fstat(fd))
    local data = assert(uv.fs_read(fd, stat.size, 0))
    assert(uv.fs_close(fd))
    return data
end

local function write_file_sync(path, data)
    local fd = assert(uv.fs_open(path, "w", 438))
    assert(uv.fs_write(fd, data, 0))
    assert(uv.fs_close(fd))
end

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

