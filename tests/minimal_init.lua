-- Minimal init.lua for testing live-preview.nvim
-- This sets up the minimal environment needed to test the plugin

-- Add current directory to runtimepath so plugin can be loaded
vim.opt.rtp:prepend(vim.fn.getcwd())

-- Add plenary to runtimepath (try multiple common locations)
local plenary_locations = {
  vim.fn.stdpath('data') .. '/lazy/plenary.nvim',
  vim.fn.stdpath('data') .. '/site/pack/*/start/plenary.nvim',
  vim.fn.stdpath('data') .. '/site/pack/*/opt/plenary.nvim',
  '~/.local/share/nvim/lazy/plenary.nvim',
  '~/.local/share/nvim/site/pack/*/start/plenary.nvim',
}

for _, path in ipairs(plenary_locations) do
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.opt.rtp:prepend(path)
    break
  end
  -- Also try globbing for pack directories
  local expanded = vim.fn.glob(path, false, true)
  if #expanded > 0 and vim.fn.isdirectory(expanded[1]) == 1 then
    vim.opt.rtp:prepend(expanded[1])
    break
  end
end

-- Basic settings for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Disable some features that might interfere with testing
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set a test-specific config directory to avoid polluting real config
local temp_dir = vim.fn.tempname()
vim.fn.mkdir(temp_dir, 'p')

vim.env.XDG_CONFIG_HOME = temp_dir .. '/config'
vim.env.XDG_DATA_HOME = temp_dir .. '/data'
vim.env.XDG_STATE_HOME = temp_dir .. '/state' 
vim.env.XDG_CACHE_HOME = temp_dir .. '/cache'

-- Make sure directories exist
vim.fn.mkdir(vim.env.XDG_CONFIG_HOME, 'p')
vim.fn.mkdir(vim.env.XDG_DATA_HOME, 'p')
vim.fn.mkdir(vim.env.XDG_STATE_HOME, 'p')
vim.fn.mkdir(vim.env.XDG_CACHE_HOME, 'p')

-- Load the plugin
require('livepreview')