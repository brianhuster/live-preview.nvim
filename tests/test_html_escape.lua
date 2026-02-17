-- Test script to verify html_escape function works correctly

-- Copy the html_escape function from template.lua
local function html_escape(text)
	if not text then
		return ""
	end

	local result = text
	-- Process & first to avoid double-escaping
	result = result:gsub("&", "&amp;")
	result = result:gsub("<", "&lt;")
	result = result:gsub(">", "&gt;")
	result = result:gsub('"', "&quot;")
	result = result:gsub("'", "&#39;")

	return result
end

-- Test cases
local test_markdown = [[$$
\begin{cases}
r_{i,k} &=& \Phi_i + (k-1)T_i \\
d_{i,k} &=& r_{i,k} + D_i
\end{cases}
$$]]

print("Original markdown:")
print(test_markdown)
print("\nHTML escaped version:")
local escaped = html_escape(test_markdown)
print(escaped)
print("\nChecking for backslashes:")
print("Original contains \\begin:", test_markdown:find("\\begin") ~= nil)
print("Escaped contains \\begin:", escaped:find("\\begin") ~= nil)
print("Escaped contains &:", escaped:find("&") ~= nil)
