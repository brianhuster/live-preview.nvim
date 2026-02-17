local template = require('lua.livepreview.template')

-- Test the html_escape function locally
local test_cases = {
    [[$$\begin{cases}x = 1 \\ y = 2\end{cases}$$]],
    [[<script>alert('xss')</script>]],
    [[Test with "quotes" and 'apostrophes']],
    [[\alpha + \beta = \gamma]],
}

for i, test in ipairs(test_cases) do
    print("Test case " .. i .. ":")
    print("Input: " .. test)
    
    -- Call md2html and check the output
    local html = template.md2html(test)
    print("HTML output contains escaped content:")
    print(html)
    print("---")
end