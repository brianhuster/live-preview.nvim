-- Tests for live-preview.nvim health checking

describe('livepreview.health', function()
  local health
  
  before_each(function()
    health = require('livepreview.health')
  end)

  describe('Neovim compatibility', function()
    it('can check Neovim version compatibility', function()
      local is_compatible = health.is_nvim_compatible()
      assert.is_boolean(is_compatible)
    end)

    it('has version information', function()
      assert.is_not_nil(health.nvim_ver)
      assert.is_string(health.nvim_ver)
      
      assert.is_not_nil(health.supported_nvim_ver_range)
      assert.is_string(health.supported_nvim_ver_range)
    end)

    it('current Neovim version should be compatible', function()
      -- In test environment, we should be using a compatible version
      local is_compatible = health.is_nvim_compatible()
      assert.is_true(is_compatible)
    end)
  end)

  describe('health spec', function()
    it('returns health specification', function()
      local spec = health.spec()
      assert.is_table(spec)
    end)

    it('has expected health check structure', function()
      local spec = health.spec()
      assert.is_not_nil(spec)
      
      -- Health spec should have required fields for Neovim's health system
      -- The exact structure depends on the implementation
      assert.is_table(spec)
    end)
  end)

  describe('dependency checks', function()
    it('can validate plugin dependencies', function()
      -- This would test checking for required dependencies
      -- The actual checks depend on what the plugin requires
      
      -- For now, just ensure health functions don't crash
      local spec = health.spec()
      assert.is_not_nil(spec)
    end)
  end)
end)