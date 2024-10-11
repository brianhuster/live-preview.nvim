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
- A modern web browser

## Installation

You can install this plugin using a plugin manager. Most plugin managers are supported. Below are some examples

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

let g:livepreview_config = {} " Optional configuration
lua require('livepreview').setup(vim.g.livepreview_config)
```

### Native package (without a plugin manager)

- **Linux, MacOS, Unix-based**

```sh
git clone https://github.com/brianhuster/live-preview.nvim ~/.config/nvim/pack/brianhuster/start/live-preview.nvim
```

- **Windows (Powershell)**

```powershell
git clone https://github.com/brianhuster/live-preview.nvim "$HOME/AppData/Local/nvim/pack/brianhuster/start/live-preview.nvim"
```

You must add the line `require('livepreview').setup()` (Lua) or `lua require('livepreview').setup()` (Vimscript) to your Neovim configuration file to enable the plugin.

## Setup

You can customize the plugin by passing a table to the `opts` variable (if you use lazy.nvim) or the function `require('livepreview').setup()`. Here is the default configuration:

### In Lua

```lua
{
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser.
        stop = 'StopPreview', -- Command to stop the live preview. 
    },
    port = 5500, -- Port to run the live preview server on.
    browser = 'default', -- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
}
```

### In Vimscript

```vim
let g:livepreview_config = {
    \ 'commands': {
        \ 'start': 'LivePreview', " Command to start the live preview server and open the default browser.
        \ 'stop': 'StopPreview', " Command to stop the live preview. 
    \ },
    \ 'port': 5500, " Port to run the live preview server on.
    \ 'browser': 'default', " Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
\ }
```

**⚠️ Important Notice:** Make sure you configure `g:livepreview_config` before calling `lua require('livepreview').setup()`.

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

![PayPal_logo](https://github.com/user-attachments/assets/297c7ee5-5745-44ca-9f20-6dd03a14180a)<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   viewBox="0 0 526.77502 140.375"
   height="140.375"
   width="526.77502"
   xml:space="preserve"
   version="1.1"
   id="svg2"><metadata
     id="metadata8"><rdf:RDF><cc:Work
         rdf:about=""><dc:format>image/svg+xml</dc:format><dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" /></cc:Work></rdf:RDF></metadata><defs
     id="defs6" /><g
     transform="matrix(1.25,0,0,-1.25,0,140.375)"
     id="g10"><g
       transform="scale(0.1,0.1)"
       id="g12"><path
         id="path14"
         style="fill:#283b82;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="m 505.703,1122.93 -327.781,0 c -22.434,0 -41.508,-16.3 -45.008,-38.45 L 0.34375,243.961 C -2.29297,227.383 10.5547,212.426 27.375,212.426 l 156.488,0 c 22.43,0 41.504,16.293 45.004,38.484 l 35.754,226.699 c 3.453,22.196 22.574,38.493 44.957,38.493 l 103.766,0 c 215.918,0 340.531,104.484 373.078,311.535 14.664,90.586 0.621,161.758 -41.797,211.603 -46.586,54.74 -129.215,83.69 -238.922,83.69 z M 543.52,815.941 C 525.594,698.324 435.727,698.324 348.832,698.324 l -49.461,0 34.699,219.656 c 2.063,13.278 13.563,23.055 26.985,23.055 l 22.668,0 c 59.191,0 115.031,0 143.882,-33.738 17.208,-20.133 22.481,-50.039 15.915,-91.356" /><path
         id="path16"
         style="fill:#283b82;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="m 1485.5,819.727 -156.96,0 c -13.37,0 -24.92,-9.778 -26.99,-23.055 l -6.94,-43.902 -10.98,15.914 c -33.98,49.32 -109.76,65.804 -185.39,65.804 -173.451,0 -321.599,-131.371 -350.451,-315.656 -15,-91.926 6.328,-179.828 58.473,-241.125 47.832,-56.363 116.273,-79.848 197.708,-79.848 139.76,0 217.26,89.86 217.26,89.86 l -7,-43.614 c -2.64,-16.679 10.21,-31.632 26.94,-31.632 l 141.38,0 c 22.48,0 41.46,16.297 45.01,38.484 l 84.83,537.234 c 2.69,16.536 -10.11,31.536 -26.89,31.536 z M 1266.71,514.23 c -15.14,-89.671 -86.32,-149.875 -177.09,-149.875 -45.58,0 -82.01,14.622 -105.401,42.325 -23.196,27.511 -32.016,66.668 -24.633,110.285 14.137,88.906 86.514,151.066 175.894,151.066 44.58,0 80.81,-14.808 104.68,-42.746 23.92,-28.23 33.4,-67.629 26.55,-111.055" /><path
         id="path18"
         style="fill:#283b82;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="m 2321.47,819.727 -157.73,0 c -15.05,0 -29.19,-7.477 -37.72,-19.989 L 1908.47,479.289 1816.26,787.23 c -5.8,19.27 -23.58,32.497 -43.71,32.497 l -155,0 c -18.84,0 -31.92,-18.403 -25.93,-36.137 L 1765.36,273.727 1602.02,43.1406 C 1589.17,24.9805 1602.11,0 1624.31,0 l 157.54,0 c 14.95,0 28.95,7.28906 37.43,19.5586 L 2343.9,776.828 c 12.56,18.121 -0.33,42.899 -22.43,42.899" /><path
         id="path20"
         style="fill:#469bdb;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="m 2843.7,1122.93 -327.83,0 c -22.38,0 -41.46,-16.3 -44.96,-38.45 L 2338.34,243.961 c -2.63,-16.578 10.21,-31.535 26.94,-31.535 l 168.23,0 c 15.62,0 29,11.402 31.44,26.933 l 37.62,238.25 c 3.45,22.196 22.58,38.493 44.96,38.493 l 103.72,0 c 215.96,0 340.53,104.484 373.12,311.535 14.72,90.586 0.58,161.758 -41.84,211.603 -46.54,54.74 -129.12,83.69 -238.83,83.69 z m 37.82,-306.989 C 2863.64,698.324 2773.78,698.324 2686.83,698.324 l -49.41,0 34.75,219.656 c 2.06,13.278 13.46,23.055 26.93,23.055 l 22.67,0 c 59.15,0 115.03,0 143.88,-33.738 17.21,-20.133 22.43,-50.039 15.87,-91.356" /><path
         id="path22"
         style="fill:#469bdb;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="m 3823.46,819.727 -156.87,0 c -13.47,0 -24.93,-9.778 -26.94,-23.055 l -6.95,-43.902 -11.02,15.914 c -33.98,49.32 -109.71,65.804 -185.34,65.804 -173.46,0 -321.55,-131.371 -350.41,-315.656 -14.95,-91.926 6.28,-179.828 58.43,-241.125 47.93,-56.363 116.27,-79.848 197.7,-79.848 139.76,0 217.26,89.86 217.26,89.86 l -7,-43.614 c -2.63,-16.679 10.21,-31.632 27.04,-31.632 l 141.34,0 c 22.38,0 41.46,16.297 44.96,38.484 l 84.88,537.234 c 2.58,16.536 -10.26,31.536 -27.08,31.536 z M 3604.66,514.23 c -15.05,-89.671 -86.32,-149.875 -177.09,-149.875 -45.49,0 -82.01,14.622 -105.4,42.325 -23.19,27.511 -31.92,66.668 -24.63,110.285 14.23,88.906 86.51,151.066 175.9,151.066 44.57,0 80.8,-14.808 104.67,-42.746 24.01,-28.23 33.5,-67.629 26.55,-111.055" /><path
         id="path24"
         style="fill:#469bdb;fill-opacity:1;fill-rule:nonzero;stroke:none"
         d="M 4008.51,1099.87 3873.97,243.961 c -2.63,-16.578 10.21,-31.535 26.94,-31.535 l 135.25,0 c 22.48,0 41.56,16.293 45.01,38.484 l 132.66,840.47 c 2.64,16.59 -10.2,31.59 -26.93,31.59 l -151.46,0 c -13.37,-0.04 -24.87,-9.83 -26.93,-23.1" /></g></g></svg>

[![Momo (Vietnam)](https://github.com/user-attachments/assets/3907d317-b62f-43f5-a231-3ec7eb4eaa1b)](https://me.momo.vn/brianphambinhan)

