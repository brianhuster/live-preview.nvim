local M = {}

local utils = require("live-preview.utils")

local min_nvim_version = "0.9.0"

local function check_command_exists(cmd)
    return vim.fn.executable(cmd) == 1
end


function M.is_compatible(min_ver)
    local nvim_ver = vim.version()
    local nvim_ver_obj = vim.version.parse(nvim_ver)
    local min_ver_obj = vim.version.parse(min_ver)
    return vim.version.compare(nvim_ver_obj, min_ver_obj) >= 0
end

M.check = function()
    vim.health.start("Live Preview Health Check")
    if not M.is_compatible(min_nvim_version) then
        vim.health.warn("Live Preview requires Neovim version " .. min_nvim_version .. " or higher")
    else
        vim.health.ok("Neovim version is compatible")
    end

    vim.health.info(
    "For Live Preview to open default browser, at least one of these commands must be executable. If you have specified a custom browser in your configuration, you can ignore this message.")
    local open_cmds = { "xdg-open", "open", "start", "rundll32", "wslview" }
    for _, cmd in ipairs(open_cmds) do
        if check_command_exists(cmd) then
            vim.health.ok(cmd .. " OK")
        else
            vim.health.warn(cmd .. "not available")
        end
    end
end

return M
