-- Tests for live-preview.nvim utility functions
local helpers = require('tests.test_helpers')

describe('livepreview.utils', function()
  local utils
  
  before_each(function()
    utils = require('livepreview.utils')
  end)

  describe('supported_filetype', function()
    it('detects HTML files', function()
      assert.are.equal('html', utils.supported_filetype('test.html'))
      assert.are.equal('html', utils.supported_filetype('path/to/test.html'))
    end)

    it('detects Markdown files', function()
      assert.are.equal('markdown', utils.supported_filetype('test.md'))
      assert.are.equal('markdown', utils.supported_filetype('test.markdown'))
      assert.are.equal('markdown', utils.supported_filetype('path/to/test.md'))
      assert.are.equal('markdown', utils.supported_filetype('path/to/test with spaces.md'))
    end)

    it('detects AsciiDoc files', function()
      assert.are.equal('asciidoc', utils.supported_filetype('test.adoc'))
      assert.are.equal('asciidoc', utils.supported_filetype('test.asciidoc'))
      assert.are.equal('asciidoc', utils.supported_filetype('path/to/test.adoc'))
    end)

    it('detects SVG files', function()
      assert.are.equal('svg', utils.supported_filetype('test.svg'))
      assert.are.equal('svg', utils.supported_filetype('path/to/test.svg'))
    end)

    it('returns nil for unsupported files', function()
      assert.is_nil(utils.supported_filetype('test.txt'))
      assert.is_nil(utils.supported_filetype('test.lua'))
      assert.is_nil(utils.supported_filetype('test.js'))
      assert.is_nil(utils.supported_filetype(''))
    end)
  end)

  describe('get_relative_path', function()
    it('returns relative path correctly', function()
      local full = '/home/user/.config/nvim/lua/livepreview/utils.lua'
      local parent = '/home/user/.config/nvim/'
      assert.are.equal('lua/livepreview/utils.lua', utils.get_relative_path(full, parent))
    end)

    it('handles parent path without trailing slash', function()
      local full = '/home/user/project/file.lua'
      local parent = '/home/user/project'
      assert.are.equal('file.lua', utils.get_relative_path(full, parent))
    end)

    it('returns nil if path is not a child', function()
      local full = '/home/user/other/file.lua'
      local parent = '/home/user/project/'
      assert.is_nil(utils.get_relative_path(full, parent))
    end)
  end)

  describe('is_absolute_path', function()
    it('detects Unix absolute paths', function()
      assert.is_true(utils.is_absolute_path('/home/user/file.lua'))
      assert.is_true(utils.is_absolute_path('/'))
    end)

    it('detects Windows absolute paths', function()
      assert.is_true(utils.is_absolute_path('C:\\Users\\user\\file.lua'))
      assert.is_true(utils.is_absolute_path('D:\\'))
    end)

    it('detects relative paths', function()
      assert.is_false(utils.is_absolute_path('lua/file.lua'))
      assert.is_false(utils.is_absolute_path('./file.lua'))
      assert.is_false(utils.is_absolute_path('../file.lua'))
      assert.is_false(utils.is_absolute_path('file.lua'))
    end)
  end)

  describe('read_file', function()
    it('reads file content correctly', function()
      local temp_file = helpers.create_temp_file('test content')
      local content = utils.read_file(temp_file)
      assert.are.equal('test content', content)
      helpers.cleanup_temp_file(temp_file)
    end)

    it('returns nil for non-existent file', function()
      local content = utils.read_file('/non/existent/file.txt')
      assert.is_nil(content)
    end)
  end)

  describe('get_plugin_path', function()
    it('returns a valid path', function()
      local plugin_path = utils.get_plugin_path()
      assert.is_string(plugin_path)
      assert.is_true(plugin_path:match('live%-preview%.nvim$') ~= nil)
    end)
  end)

  describe('list_supported_files', function()
    it('returns a table of supported files', function()
      local plugin_path = utils.get_plugin_path()
      local files = utils.list_supported_files(plugin_path)
      assert.is_table(files)
      -- Should find at least README.md in the plugin directory
      assert.is_true(#files > 0)
    end)
  end)
end)