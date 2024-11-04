# Introduction

live-preview.nvim is a plugin for Neovim that allows you to view Markdown, HTML (along with CSS, JavaScript) and AsciiDoc files in a web browser with live updates. No external dependencies or runtime like NodeJS or Python are required, since the backend is fully written in Lua and Neovim's built-in functions.

# Features
 
* Supports markdown, HTML (with reference to CSS, JS), and AsciiDoc files 📄
* Support Katex for rendering math equations in markdown and AsciiDoc files 🧮
* Supports mermaid for rendering diagrams in markdown files 🖼️
* Syntax highlighting for code blocks in Markdown and AsciiDoc 🖍️
* Supports sync scrolling in the browser as you scroll in the Markdown files in Neovim. (You need to enable `sync_scroll` in [setup](#setup). This feature should be used with [brianhuster/autosave.nvim](https://github.com/brianhuster/autosave.nvim)) 🔄
* Integration with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 🔭

# Requirements
 
- Neovim >=0.10.0 (recommended: >=0.10.1)
- A modern web browser 🌐
- PowerShell (only if you use Windows) 🪟

# Installation
 
You can install this plugin using a plugin manager. Most plugin managers are supported. Below are some examples

<details>
<summary>Using lazy.nvim (recommended) 💤</summary>

```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {
            'brianhuster/autosave.nvim'  -- Not required, but recomended for autosaving and sync scrolling
            'nvim-telescope/telescope.nvim' -- Not required, but recommended for integrating with Telescope
        },
        opts = {},
   }
})
```

</details>

<details>
<summary>mini.deps 📦</summary>

```lua
MiniDeps.add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 
        'brianhuster/autosave.nvim'  -- Not required, but recomended for autosaving and sync scrolling
        'nvim-telescope/telescope.nvim' -- Not required, but recommended for integrating with Telescope
    }, 
})
```

</details>

<details>
<summary>rocks.nvim 🪨</summary>

```vim
:Rocks install live-preview.nvim
```
</details>

<details>
<summary>vim-plug 🔌</summary>

```vim
Plug 'brianhuster/live-preview.nvim'

Plug 'nvim-telescope/telescope.nvim' " Not required, but recommended for integrating with Telescope

Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
```

</details>

<details>
<summary>Native package (without a plugin manager) 📦</summary>

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim
```

</details>

# Setup
 
You can customize the plugin by passing a table to the `opts` variable (if you use lazy.nvim) or the function `require('livepreview').setup()`. Here is the default configuration:

## In Lua

```lua
{
    cmd = "LivePreview", -- Main command of live-preview.nvim
    port = 5500, -- Port to run the live preview server on.
    autokill = false, -- If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
    browser = 'default', -- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
    dynamic_root = false, -- If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:lua print(vim.uv.cwd())`).
    sync_scroll = false, -- If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
    picker = nil, -- Picker to use for opening files. 3 choices are available: 'telescope', 'fzf-lua', 'mini.pick'. If nil, the plugin look for the first available picker when you call the `pick` command.
}
```

## In Vimscript
 
```vim
`call v:lua.require('livepreview').setup({
    \ 'cmd': 'LivePreview', 
    \ 'port': 5500, 
    \ 'autokill': v:false, 
    \ 'browser': 'default', 
    \ 'dynamic_root': v:false, 
    \ 'sync_scroll': v:false, 
    \ 'picker': v:false, 
\ })
```

# Usage
 
## For default configuration (`opt.cmd = "LivePreview"`)
 
* To start the live preview, use the command:

`:LivePreview start`

This command will open the current Markdown or HTML file in your default web browser and update it live as you write changes to your file.

You can also parse a file path as argument, for example `:LivePreview start test/doc.md`

* To stop the live preview server, use the command:

`:LivePreview close`

* To open a picker and select a file to preview, use the command:

`:LivePreview pick`

* To see document about each subcommand, use the command:

`:LivePreview help`

This requires a picker to be installed (Telescope, fzf-lua or mini.pick). If you have multiple pickers installed, you can specify the picker to use by passing the picker name to the configuration table (see [setup](#setup))

Use the command `:help livepreview` to see the help documentation.

## API

For API documentation, please refer to |livepreview-api|

# Change log

See |livepreview-changelog|

# License

This project is licensed under GPL-3.0. 

Copyright (C) 2024 Phạm Bình An
