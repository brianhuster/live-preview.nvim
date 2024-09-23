local M = {}

M.plugin = {}

M.plugin.__index = M.plugin


M.available_plugins = function()
    return {
        {
            name = "marked",
            description = "A markdown parser",
            filetype = "markdown",
            url = "https://github.com/brianhuster/marked",
        },
        {
            name = "github-markdown-css",
            description = "A markdown style that looks like github",
            url = "https://github.com/brianhuster/github-markdown-css",
        },
        {
            name = "asciidoctor",
            description = "An AsciiDoc parser",
            filetype = "asciidoc",
            url = "https://github.com/brianhuster/asciidoctor",
        },
        {
            name = "asciidoctor-css",
            description = "A style for AsciiDoc",
            url = "https://github.com/brianhuster/asciidoctor-css",
        },
    }
end
