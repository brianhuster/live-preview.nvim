# Unicode Character Rendering Fix

## Problem
When previewing HTML files containing Chinese, Japanese, Korean, or other Unicode characters, the browser displayed garbled text because the HTTP `Content-Type` header didn't specify the character encoding.

## Root Cause
The server was sending:
```
Content-Type: text/html
```

Without an explicit charset, browsers default to encodings like ISO-8859-1 or Windows-1252, which cannot properly represent Unicode characters.

## Solution
Modified `/lua/livepreview/server/utils/content_type.lua` to include `charset=UTF-8` for text-based MIME types:

```lua
["html"] = "text/html; charset=UTF-8",
["htm"] = "text/html; charset=UTF-8",
["xhtml"] = "application/xhtml+xml; charset=UTF-8",
["xht"] = "application/xhtml+xml; charset=UTF-8",
["css"] = "text/css; charset=UTF-8",
["js"] = "text/javascript; charset=UTF-8",
["mjs"] = "text/javascript; charset=UTF-8",
["xml"] = "application/xml; charset=UTF-8",
["svg"] = "image/svg+xml; charset=UTF-8",
["svgz"] = "image/svg+xml; charset=UTF-8",
["txt"] = "text/plain; charset=UTF-8",
```

## Result
The server now sends:
```
Content-Type: text/html; charset=UTF-8
```

This ensures browsers correctly interpret Unicode characters in all supported text-based file formats.

## Testing
Created `tests/test-unicode.html` with:
- Chinese characters: 你好世界
- Japanese characters: これは日本語のテストです
- Korean characters: 한국어 테스트
- Emoji: 🌟 🎉 🚀 ❤️ 🌈
- Math symbols: ∀ ∃ ∈ ∉ ∅
- Special characters: € £ ¥ ₹ ₽

All characters now render correctly in the browser preview.

## Why Markdown Files Worked
Markdown files were already working because the `html_template()` function includes:
```html
<meta charset="UTF-8">
```

However, HTML files served directly lacked both:
1. The HTTP `Content-Type` charset parameter
2. The `<meta charset>` tag (user's responsibility)

This fix ensures that even HTML files without a `<meta charset>` tag will be correctly interpreted by the browser.

## Impact
- **Before**: Unicode characters displayed as �, Ã,Æ—‡Å, or other garbled text
- **After**: All Unicode characters display correctly

This fix affects:
- HTML files (.html, .htm, .xhtml, .xht)
- CSS files with Unicode content
- JavaScript files with Unicode strings
- SVG files with Unicode text
- XML files with Unicode content
- Plain text files

## Files Changed
1. `lua/livepreview/server/utils/content_type.lua` - Added charset=UTF-8 to 11 MIME types
2. `tests/test-unicode.html` - New test file with comprehensive Unicode examples
3. `tests/test-unicode-fix.js` - Automated test to verify the fix
