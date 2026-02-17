-- Debug script to test if template.lua is being loaded correctly
-- Run this in Neovim with :luafile debug_template.lua

local template = require('livepreview.template')

local test_md = [[$$
\begin{cases}
x = 1 \\
y = 2
\end{cases}
$$]]

print("=== Testing template.md2html ===")
print("\nInput markdown:")
print(test_md)

local html = template.md2html(test_md)

print("\n=== Output HTML (first 2000 chars) ===")
print(html:sub(1, 2000))

print("\n=== Checking for escaped content ===")
print("Contains &amp;:", html:find("&amp;") ~= nil)
print("Contains &lt;:", html:find("&lt;") ~= nil)
print("Contains \\begin:", html:find("\\begin") ~= nil)
print("Contains &lt;begin:", html:find("&lt;begin") ~= nil)

print("\n=== Full markdown-body content ===")
local body_content = html:match('<div class="markdown%-body">(.-)</div>')
if body_content then
    print(body_content)
else
    print("Could not extract body content")
end