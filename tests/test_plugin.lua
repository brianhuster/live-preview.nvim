-- Tests for live-preview.nvim plugin functionality
-- These are functional tests that test the actual plugin behavior

local helpers = require('tests.test_helpers')

describe('livepreview plugin', function()
  local livepreview
  local temp_file

  before_each(function()
    -- Clean state for each test
    if livepreview and livepreview.is_running() then
      livepreview.close()
    end
    livepreview = require('livepreview')
  end)

  after_each(function()
    -- Cleanup after each test
    if livepreview and livepreview.is_running() then
      livepreview.close()
    end
    if temp_file then
      helpers.cleanup_temp_file(temp_file)
      temp_file = nil
    end
  end)

  describe('plugin state', function()
    it('is not running initially', function()
      assert.is_false(livepreview.is_running())
    end)

    it('can check if server is running', function()
      assert.is_false(livepreview.is_running())
      -- After starting, it should be running
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4000)
      livepreview.start(temp_file, port)
      
      -- Wait a moment for server to start
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      
      assert.is_true(livepreview.is_running())
    end)

    it('can start and stop server', function()
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4001)
      
      -- Start server
      livepreview.start(temp_file, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
      
      -- Stop server  
      livepreview.close()
      helpers.wait_for_condition(function()
        return not livepreview.is_running()
      end, 2000)
      assert.is_false(livepreview.is_running())
    end)
  end)

  describe('file type support', function()
    it('works with markdown files', function()
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4002)
      
      local result = livepreview.start(temp_file, port)
      assert.is_true(result)
      
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
    end)

    it('works with HTML files', function()
      temp_file = helpers.create_temp_file(helpers.test_html_content(), 'html')
      local port = helpers.find_free_port(4003)
      
      local result = livepreview.start(temp_file, port)
      assert.is_true(result)
      
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
    end)

    it('works with AsciiDoc files', function()
      temp_file = helpers.create_temp_file(helpers.test_asciidoc_content(), 'adoc')
      local port = helpers.find_free_port(4004)
      
      local result = livepreview.start(temp_file, port)
      assert.is_true(result)
      
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
    end)
  end)

  describe('server functionality', function()
    it('uses the specified port', function()
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4005)
      
      livepreview.start(temp_file, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      
      -- Check that the port is now in use
      assert.is_true(helpers.is_port_in_use(port))
    end)

    it('handles multiple start/stop cycles', function()
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4006)
      
      -- First cycle
      livepreview.start(temp_file, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
      
      livepreview.close()
      helpers.wait_for_condition(function()
        return not livepreview.is_running()
      end, 2000)
      assert.is_false(livepreview.is_running())
      
      -- Second cycle  
      livepreview.start(temp_file, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
    end)

    it('can handle starting server when one is already running', function()
      temp_file = helpers.create_temp_file(helpers.test_markdown_content(), 'md')
      local port = helpers.find_free_port(4007)
      
      -- Start first server
      livepreview.start(temp_file, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
      
      -- Start second server (should replace first)
      local temp_file2 = helpers.create_temp_file(helpers.test_html_content(), 'html')
      livepreview.start(temp_file2, port)
      helpers.wait_for_condition(function()
        return livepreview.is_running()
      end, 2000)
      assert.is_true(livepreview.is_running())
      
      helpers.cleanup_temp_file(temp_file2)
    end)
  end)
end)