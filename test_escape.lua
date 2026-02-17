local function html_escape(text)
    if not text then return "" end
    local result = text
    result = result:gsub("&", "&amp;")
    result = result:gsub("<", "&lt;")
    result = result:gsub(">", "&gt;")
    result = result:gsub('"', "&quot;")
    result = result:gsub("'", "&#39;")
    return result
end

local test = [[$$
\begin{cases}
x = 1 \\
y = 2
\end{cases}
$$]]

print("Original:")
print(test)
print("\nEscaped:")
print(html_escape(test))
print("\n\nTest: Contains backslash before 'begin':")
print(string.find(test, "\\begin") ~= nil)
