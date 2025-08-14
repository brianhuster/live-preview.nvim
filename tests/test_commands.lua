-- Tests for live-preview.nvim commands using child Neovim instances
-- This tests the actual :LivePreview commands via RPC

local helpers = require('tests.test_helpers')

describe('LivePreview commands', function()
  local child
  
  before_each(function()
    -- Start a child Neovim instance for testing
    child = vim.loop.spawn('nvim', {
      args = {
        '--headless',
        '--clean',
        '-u', 'tests/minimal_init.lua',
        '--listen', '127.0.0.1:0', -- Dynamic port allocation
      },
      stdio = { nil, nil, nil }
    })
    
    -- Give child time to start
    vim.wait(500)
  end)

  after_each(function()
    if child then
      child:kill('sigterm')
      child:close()
      child = nil
    end
  end)

  -- Note: These tests are more complex to implement properly with child processes
  -- For now, we'll focus on the simpler unit tests and basic functionality tests
  -- Real RPC-based testing would require more setup and infrastructure
  
  pending('LivePreview start command works', function()
    -- This would test the actual :LivePreview start command via RPC
    -- Implementation would involve:
    -- 1. Connecting to child Neovim via RPC
    -- 2. Opening a markdown file in the child
    -- 3. Running :LivePreview start
    -- 4. Verifying server starts and browser opens
  end)

  pending('LivePreview close command works', function()
    -- This would test the :LivePreview close command
  end)

  pending('LivePreview pick command works', function()  
    -- This would test the :LivePreview pick command
  end)

  pending('Command completion works', function()
    -- This would test that tab completion works for LivePreview commands
  end)

  pending('Error handling for unsupported files', function()
    -- This would test error messages for unsupported file types
  end)
end)

-- For now, let's add some basic tests that don't require child processes
describe('LivePreview command registration', function()
  it('registers the LivePreview command', function()
    -- Check that the command exists
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands['LivePreview'])
  end)

  it('has correct command attributes', function()
    local commands = vim.api.nvim_get_commands({})
    local lp_cmd = commands['LivePreview']
    
    assert.is_not_nil(lp_cmd)
    assert.is_true(lp_cmd.nargs == '*')
    assert.is_not_nil(lp_cmd.complete)
  end)
end)

describe('LivePreview API', function()
  it('exposes LivePreview global table', function()
    assert.is_not_nil(LivePreview)
    assert.is_table(LivePreview)
  end)

  it('has config table', function()
    assert.is_not_nil(LivePreview.config)
    assert.is_table(LivePreview.config)
  end)

  it('has expected config options', function()
    -- Test some known config options exist
    local config = LivePreview.config
    assert.is_not_nil(config.port)
    assert.is_not_nil(config.browser)
  end)
end)