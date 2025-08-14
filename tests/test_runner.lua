#!/usr/bin/env lua

-- Simple test runner for live-preview.nvim tests
-- This is a fallback when plenary.test is not available

local function run_basic_tests()
  print("Running basic tests for live-preview.nvim...")
  print()
  
  -- Set up basic Lua path to find modules
  local current_dir = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
  local project_root = current_dir:gsub("/tests/", "/"):gsub("/scripts/", "/")
  
  -- Add project lua directory to path
  package.path = project_root .. "lua/?.lua;" .. 
                 project_root .. "lua/?/init.lua;" .. 
                 project_root .. "tests/?.lua;" .. 
                 package.path

  -- Mock vim table for basic testing
  _G.vim = {
    fn = {
      tempname = function() return os.tmpname() end,
      filereadable = function(file) 
        local f = io.open(file, "r")
        if f then f:close(); return 1 else return 0 end
      end,
      delete = function(file) os.remove(file) end,
      getcwd = function() return "." end,
    },
    fs = {
      normalize = function(path) return path end,
      joinpath = function(...) return table.concat({...}, "/") end,
      basename = function(path) return path:match("([^/]+)$") end,
      dirname = function(path) return path:match("(.+)/[^/]*$") or "." end,
    },
    opt = {},
    wait = function(ms) os.execute("sleep " .. (ms/1000)) end,
    uv = {
      hrtime = function() return os.clock() * 1000000000 end,
      cwd = function() return "." end,
    },
    json = {
      decode = function(str) 
        -- Very basic JSON decode for pkg.json
        if str:match('"name":%s*"live%-preview%.nvim"') then
          return { name = "live-preview.nvim" }
        end
        return {}
      end
    }
  }

  -- Basic test runner
  local function test_utils()
    print("Testing livepreview.utils...")
    
    local utils = require('livepreview.utils')
    
    -- Test supported_filetype
    assert(utils.supported_filetype("test.html") == "html", "HTML detection failed")
    assert(utils.supported_filetype("test.md") == "markdown", "Markdown detection failed")
    assert(utils.supported_filetype("test.adoc") == "asciidoc", "AsciiDoc detection failed")
    assert(utils.supported_filetype("test.txt") == nil, "Unsupported file detection failed")
    
    -- Test is_absolute_path
    assert(utils.is_absolute_path("/home/user/file.lua") == true, "Unix absolute path detection failed")
    assert(utils.is_absolute_path("relative/path.lua") == false, "Relative path detection failed")
    
    print("✓ Utils tests passed")
  end

  local function test_config()
    print("Testing livepreview.config...")
    
    local config = require('livepreview.config')
    
    -- Test that config has expected structure
    assert(config.default ~= nil, "Default config missing")
    assert(type(config.default.port) == "number", "Port config invalid")
    assert(type(config.default.browser) == "string", "Browser config invalid")
    
    print("✓ Config tests passed")  
  end

  -- Run tests
  local success = true
  
  local function safe_run(test_func, name)
    local ok, err = pcall(test_func)
    if not ok then
      print("✗ " .. name .. " failed: " .. tostring(err))
      success = false
    end
  end
  
  safe_run(test_utils, "Utils tests")
  safe_run(test_config, "Config tests")
  
  print()
  if success then
    print("All basic tests passed! ✓")
    os.exit(0)
  else
    print("Some tests failed! ✗")
    os.exit(1)
  end
end

if arg and arg[0] and arg[0]:match("test_runner%.lua$") then
  run_basic_tests()
end

return { run_basic_tests = run_basic_tests }