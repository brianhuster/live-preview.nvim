local M = {}

local utils = require("live-preview.utils")

local function check_command_exists(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not handle then
        return false
    end
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

local function check_node_modules()
    local directory = utils.get_parent_path(utils.get_path_lua_file(), "lua/live-preview/health.lua")

    local node_modules = {
        "ejs",
        "express",
        "fs",
        "marked",
        "path",
        "ws"
    }

    local missing_modules = {}

    for _, module in ipairs(node_modules) do
        local module_path = directory .. "/node_modules/" .. module
        local stat = vim.uv.fs_stat(module_path)

        if not stat then
            table.insert(missing_modules, module)
        end
    end

    return missing_modules
end

local function check_nodemon()
    local handle = io.popen("npm list -g nodemon 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result:find("nodemon") ~= nil
end

M.check = function()
    vim.health.start("Live Preview Health Check")

    -- Check for Node.js
    if not check_command_exists("node") then
        vim.health.error("Node.js is not installed")
    else
        vim.health.ok("Node.js is installed")
    end

    -- Check for npm
    if not check_command_exists("npm") then
        vim.health.error("npm is not installed")
    else
        vim.health.ok("npm is installed")
    end

    -- Check for nodemon
    if not check_nodemon() then
        vim.health.error("Nodemon is not installed")
    else
        vim.health.ok("Nodemon is installed")
    end

    -- Check for required node modules
    local missing_modules = check_node_modules()
    if #missing_modules > 0 then
        vim.health.error("Missing Node.js modules: " .. table.concat(missing_modules, ", "))
    else
        vim.health.ok("All required Node.js modules are installed")
    end
end

return M
