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

- **Linux, MacOS, Unix-based** 🐧🍎

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.config/nvim/pack/brianhuster/start/live-preview.nvim
```

- **Windows (Powershell) 🪟**

```powershell
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim "$HOME/AppData/Local/nvim/pack/brianhuster/start/live-preview.nvim"
```

</details>

# Setup
 
You can customize the plugin by passing a table to the `opts` variable (if you use lazy.nvim) or the function `require('livepreview').setup()`. Here is the default configuration:

## In Lua

```lua
{
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser.
        stop = 'StopPreview', -- Command to stop the live preview. 
    },
    port = 5500, -- Port to run the live preview server on.
    autokill = false, -- If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
    browser = 'default', -- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
    dynamic_root = false, -- If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:lua print(vim.uv.cwd())`).
    sync_scroll = false, -- If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
    telescope = {
        false, -- If true, the plugin will automatically load the `Telescope livepreview` extension.
    },
}
```

## In Vimscript
 
```vim
let g:livepreview_config = {
    \ 'commands': {
        \ 'start': 'LivePreview', " Command to start the live preview server and open the default browser.
        \ 'stop': 'StopPreview', " Command to stop the live preview. 
    \ },
    \ 'autokill': v:false, " If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
    \ 'port': 5500, " Port to run the live preview server on.
    \ 'browser': 'default', " Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
    \ 'dynamic_root': v:false " If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:pwd`).
    \ 'sync_scroll': v:false " If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
    \ 'telescope': {
    \   'autoload' : v:false " If true, the plugin will automatically load the `Telescope livepreview` extension.
    \ },
\ }
lua require('livepreview').setup(vim.g.livepreview_config)
```

# Usage
 
## For default configuration 
 
To start the live preview, use the command:

`:LivePreview`

This command will open the current Markdown or HTML file in your default web browser and update it live as you write changes to your file.

You can also parse a file path as argument, for example `:LivePreview test/doc.md`

To stop the live preview server, use the command:

`:StopPreview`

These commands can be changed based on your customization in the `setup` function in your Neovim configuration file. 

Use the command `:help livepreview` to see the help documentation.

## Integration with Telescope
 
To use this feature, you need to install [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

Then set `telescope.autoload` to `true` in the [configuration table](#setup) of live-preview.nvim

Alternatively, you can load the extension in your Neovim configuration file:
```lua
require('telescope').load_extension('live_preview')
```
Now you can use the command `:Telescope livepreview` to open live-preview.nvim's Telescope interface.

## API

For API documentation, please refer to |livepreview-api|

# Change log

See |livepreview-changelog|

# License

This project is licensed under GPL-3.0. 

Copyright (C) 2024 Phạm Bình An
