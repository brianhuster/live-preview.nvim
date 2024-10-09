# live-preview.nvim
A plugin for Neovim that allows you to view [Markdown](https://en.wikipedia.org/wiki/Markdown), [HTML](https://en.wikipedia.org/wiki/HTML) (along with CSS, JavaScript) and [AsciiDoc](https://asciidoc.org/) files in a web browser with live updates. No external dependencies or runtime are required, since the backend is fully written in Lua and Neovim's built-in functions.

_You can read this README in [Tiếng Việt](README.vi.md)_

## Features
Supports markdown, HTML (with reference to CSS, JS), and AsciiDoc files

Support Katex for rendering math equations in markdown and AsciiDoc files

Supports mermaid for rendering diagrams in markdown files

### Updates

See [RELEASE.md](RELEASE.md) 

**⚠️ Important Notice:** You must clear the cache of the browser after updating to ensure the plugin works correctly.

## Demo video

https://github.com/user-attachments/assets/865112c1-8514-4920-a531-b2204194f749

## Requirements

- Neovim >=0.10.0
    (recommended >=0.10.2)
- A modern web browser

## Installation

### Using lazy.nvim (recommended)

```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- Not required, but recomended for autosaving
        opts = {},
    }
})
```

### mini.deps
```lua
add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 'brianhuster/autosave.nvim' }, -- Not required, but recomended for autosaving
})
require('livepreview').setup()
```

### vim-plug
```vim
Plug 'brianhuster/live-preview.nvim'
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
lua EOF
require('livepreview').setup()
EOF
```

## Setup

You can customize the plugin by passing a table to the `opts` variable or the function `require('livepreview').setup()`. Here is the default configuration:

```lua
{
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser.
        stop = 'StopPreview', -- Command to stop the live preview. 
    },
    port = 5500, -- Port to run the live preview server on. Default is 5500
    browser = {}, -- Table of browsers to open the live preview in. By default, it will use the default browser of your system. This option is only configurable on Neovim 0.10.2 and later.
}
```

## Usage

### For default configuration 

To start the live preview, use the command:

`:LivePreview`

This command will open the current Markdown or HTML file in your default web browser and update it live as you write changes to your file.

To stop the live preview server, use the command:

`:StopPreview`

These commands can be changed based on your customization in the `setup` function in your Neovim configuration file. 

Use the command `:help livepreview` to see the help documentation.

## Contributing

Since this is a young project, there should be a lot of rooms for improvements. If you would like to contribute to this project, please feel free to open an issue or a pull request.

## TODO
- [x] Support for KaTex math in Markdown and AsciiDoc
- [x] Support for Mermaid diagrams in Markdown
- [ ] Autoscroll in the browser as you scroll in the Markdown and AsciiDoc files in Neovim
- [ ] Support for diagrams in AsciiDoc

## Acknowledgements
* [glacambre/firenvim](https://github.com/glacambre/firenvim) for the sha1 function
* [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) and [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) for the idea inspiration
* [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css) CSS style for Markdown files
* [markedjs/marked](https://github.com/markedjs/marked) for parsing Markdown files
* [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js) for parsing AsciiDoc files
* [KaTeX](https://github.com/KaTeX/KaTeX) for rendering math equations
* [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) for rendering diagrams

### Buy me a coffee
Maintaining this project takes time and effort, especially as I am a student now. If you find this project helpful, please consider supporting me :>

#### Paypal
[https://www.paypal.com/paypalme/brianphambinhan](https://www.paypal.com/paypalme/brianphambinhan)

#### Momo (Vietnam)
[https://me.momo.vn/brianphambinhan](https://me.momo.vn/brianphambinhan)
