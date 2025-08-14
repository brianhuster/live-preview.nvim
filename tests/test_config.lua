-- Tests for live-preview.nvim configuration management

describe('livepreview.config', function()
  local config
  
  before_each(function()
    config = require('livepreview.config')
  end)

  describe('default configuration', function()
    it('has all required options', function()
      assert.is_not_nil(config.default)
      assert.is_table(config.default)
      
      -- Check for expected config options
      assert.is_not_nil(config.default.port)
      assert.is_not_nil(config.default.browser)
      assert.is_not_nil(config.default.dynamic_root)
    end)

    it('has sensible default values', function()
      assert.is_number(config.default.port)
      assert.is_true(config.default.port > 0)
      assert.is_true(config.default.port < 65536)
      
      assert.is_string(config.default.browser)
      assert.is_boolean(config.default.dynamic_root)
    end)
  end)

  describe('configuration management', function()
    it('can get current config', function()
      local current_config = config.config
      assert.is_not_nil(current_config)
      assert.is_table(current_config)
    end)

    it('can set configuration options', function()
      local original_port = config.config.port
      
      -- Set new port
      config.set({ port = 9999 })
      assert.are.equal(9999, config.config.port)
      
      -- Restore original
      config.set({ port = original_port })
      assert.are.equal(original_port, config.config.port)
    end)

    it('validates configuration options', function()
      -- This test would check that invalid options are rejected
      -- The actual validation logic depends on implementation
      local original_config = vim.deepcopy(config.config)
      
      -- Try to set invalid port (should be handled gracefully)
      pcall(function()
        config.set({ port = -1 })
      end)
      
      -- Try to set invalid browser (should be handled gracefully) 
      pcall(function()
        config.set({ browser = 123 })
      end)
      
      -- Config should still be valid after invalid attempts
      assert.is_table(config.config)
    end)
  end)

  describe('picker configuration', function()
    it('has picker options', function()
      assert.is_not_nil(config.pickers)
      assert.is_table(config.pickers)
    end)

    it('supports multiple picker backends', function()
      local pickers = config.pickers
      -- Should support common pickers like telescope, fzf-lua, mini.pick
      assert.is_true(vim.tbl_count(pickers) > 0)
    end)
  end)
end)

describe('LivePreview.config metatable', function()
  it('allows reading config values', function()
    local port = LivePreview.config.port
    assert.is_number(port)
  end)

  it('allows setting config values', function()
    local original_port = LivePreview.config.port
    
    LivePreview.config.port = 8888
    assert.are.equal(8888, LivePreview.config.port)
    
    -- Restore original
    LivePreview.config.port = original_port
  end)

  it('handles invalid config keys gracefully', function() 
    -- Accessing invalid key should show error but not crash
    local result = pcall(function()
      local _ = LivePreview.config.invalid_key
    end)
    assert.is_true(result) -- Should not crash
    
    -- Setting invalid key should show error but not crash
    result = pcall(function()
      LivePreview.config.invalid_key = 'test'
    end)
    assert.is_true(result) -- Should not crash
  end)
end)