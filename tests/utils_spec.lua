local utils = require('livepreview.utils')

print('Test module livepreview.utils')

print()
print('supported_filetype()')
assert(utils.supported_filetype('test.html') == 'html', 'should returns `html`')
assert(utils.supported_filetype('test.md') == 'markdown', 'should returns `markdown`')
assert(utils.supported_filetype('test.markdown') == 'markdown', 'should returns `markdown`')
assert(utils.supported_filetype('test.adoc') == 'asciidoc', 'should returns `asciidoc`')
assert(utils.supported_filetype('test.asciidoc') == 'asciidoc', 'should returns `asciidoc`')
assert(utils.supported_filetype('test.txt') == nil, 'should returns `nil`')
assert(utils.supported_filetype('test/test.html') == 'html', 'should returns `html`')
assert(utils.supported_filetype('test/test.md') == 'markdown', 'should returns `markdown`')
assert(utils.supported_filetype('test/test.markdown') == 'markdown', 'should returns `markdown`')
assert(utils.supported_filetype('test/test.adoc') == 'asciidoc', 'should returns `asciidoc`')
assert(utils.supported_filetype('test/test.asciidoc') == 'asciidoc', 'should returns `asciidoc`')
assert(utils.supported_filetype('test/test.txt') == nil, 'should returns `nil`')

print()
print('get_plugin_path()')
local plugin_path = utils.get_plugin_path()
print(plugin_path)
assert(plugin_path:match('live%-preview%.nvim$'), 'should returns the path where live-preview.nvim is installed')

print()
print('list_supported_files()')
local supported_files = utils.list_supported_files(plugin_path)
assert(type(supported_files) == 'table' and #supported_files > 0, 'should returns a table with values')

print()
print('read_file()')
local raw_packspec = utils.read_file(vim.fs.joinpath(plugin_path, 'pkg.json'))
assert(type(raw_packspec) == 'string' and #raw_packspec > 0, 'should returns a string with content')
assert(vim.json.decode(raw_packspec), 'The content of pkg.json should be a valid JSON string')

print()
print('get_relative_path()')
local relative_path = utils.get_relative_path("/home/user/.config/nvim/lua/livepreview/utils.lua",
	"/home/user/.config/nvim/")
assert(relative_path == "lua/livepreview/utils.lua", 'should returns the relative path')

print()
assert(utils.joinpath("home", "user", "file.txt") == "home/user/file.txt", 'should returns the joined path')
assert(utils.joinpath("home", "user", "folder", "../file.txt") == "home/user/file.txt", 'should returns the joined path')

print()
print('is_absolute_path()')
assert(utils.is_absolute_path("/home/user/.config/nvim/lua/livepreview/utils.lua"), 'should returns true in Unix')
assert(utils.is_absolute_path("C:\\Users\\user\\AppData\\Local\\nvim\\lua\\livepreview\\utils.lua"),
	'should returns true in Windows')
assert(not utils.is_absolute_path("lua/livepreview/utils.lua"), 'should returns false')
