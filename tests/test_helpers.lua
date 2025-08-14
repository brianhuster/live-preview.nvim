-- Test utilities for live-preview.nvim tests
local M = {}

-- Helper to create temporary files for testing
function M.create_temp_file(content, extension)
  extension = extension or 'md'
  local temp_file = vim.fn.tempname() .. '.' .. extension
  local file = io.open(temp_file, 'w')
  if file then
    file:write(content)
    file:close()
  end
  return temp_file
end

-- Helper to clean up temporary files
function M.cleanup_temp_file(filepath)
  if filepath and vim.fn.filereadable(filepath) == 1 then
    vim.fn.delete(filepath)
  end
end

-- Helper to wait for condition with timeout
function M.wait_for_condition(condition, timeout, interval)
  timeout = timeout or 1000 -- 1 second default
  interval = interval or 50 -- 50ms default
  local start_time = vim.uv.hrtime()
  
  while (vim.uv.hrtime() - start_time) / 1000000 < timeout do
    if condition() then
      return true
    end
    vim.wait(interval)
  end
  
  return false
end

-- Helper to check if a port is in use
function M.is_port_in_use(port)
  local handle = vim.uv.new_tcp()
  local success = pcall(function()
    handle:bind('127.0.0.1', port)
  end)
  handle:close()
  return not success
end

-- Helper to find a free port for testing
function M.find_free_port(start_port)
  start_port = start_port or 3000
  for port = start_port, start_port + 100 do
    if not M.is_port_in_use(port) then
      return port
    end
  end
  error('Could not find a free port for testing')
end

-- Helper to create test markdown content
function M.test_markdown_content()
  return [[# Test Markdown File

This is a test markdown file for live-preview.nvim testing.

## Features

- Live preview of markdown files
- Auto-refresh on save
- WebSocket communication

## Code Example

```lua
local M = {}
return M
```

That's all folks!]]
end

-- Helper to create test HTML content  
function M.test_html_content()
  return [[<!DOCTYPE html>
<html>
<head>
    <title>Test HTML File</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Test HTML File</h1>
    <p>This is a test HTML file for live-preview.nvim testing.</p>
    <script>
        console.log('Test HTML loaded');
    </script>
</body>
</html>]]
end

-- Helper to create test AsciiDoc content
function M.test_asciidoc_content()
  return [[= Test AsciiDoc File
:toc:

This is a test AsciiDoc file for live-preview.nvim testing.

== Features

* Live preview of AsciiDoc files  
* Auto-refresh on save
* WebSocket communication

== Code Example

[source,lua]
----
local M = {}
return M
----

That's all folks!]]
end

return M