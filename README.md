# Introduction :wave:

[![LuaRocks](https://img.shields.io/luarocks/v/brianhuster/live-preview.nvim?logo=lua&color=purple)](https://luarocks.org/modules/brianhuster/live-preview.nvim)

live-preview.nvim is a plugin for Neovim that allows you to view [Markdown](https://en.wikipedia.org/wiki/Markdown), [HTML](https://en.wikipedia.org/wiki/HTML) (along with CSS, JavaScript), [AsciiDoc](https://asciidoc.org/) and [SVG](https://en.wikipedia.org/wiki/SVG) files in a web browser with live updates. No external dependencies or runtime like NodeJS or Python are required, since the backend is fully written in Lua and Neovim's built-in functions.

# Features :sparkles:
 
* Preview Markdown, AsciiDoc, SVG with live updates as you type 
* Preview HTML (with CSS and JavaScript) with live updates as you save the file
* Supports KaTeX and Mermaid for rendering math equations and diagrams in Markdown and AsciiDoc files
* Syntax highlighting for code blocks in Markdown and AsciiDoc 🖍️
* Supports sync scrolling in the browser as you scroll in the Markdown files in Neovim. 
* Integration with [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) 🔭, [`fzf-lua`](https://github.com/ibhagwan/fzf-lua), [`mini.pick`](https://github.com/echasnovski/mini.pick) and `vim.ui.select` meaning pickers like [`snacks.nvim`](https://gothub.com/folke/snacks.nvim) is supported

# Updates :loudspeaker:
 
See [RELEASE.md](RELEASE.md) 

**⚠️ Important Notice:** You should clear the cache of the browser after updating to ensure the plugin works correctly.

# Demo video :movie_camera:
 
https://github.com/user-attachments/assets/865112c1-8514-4920-a531-b2204194f749

# Installation :package:

**Requirements** 

- Neovim >=0.10.1
- A modern web browser 
- PowerShell (only if you use Windows) 
 
You can install this plugin using a plugin manager. Most plugin managers are supported. Below are some examples

<details>
<summary>Using lazy.nvim (recommended) 💤</summary>

```lua
{
    'brianhuster/live-preview.nvim',
    dependencies = {
        -- You can choose one of the following pickers
        'nvim-telescope/telescope.nvim',
        'ibhagwan/fzf-lua',
        'echasnovski/mini.pick',
		'folke/snacks.nvim',
    },
}
```

</details>

<details>
<summary>mini.deps 📦</summary>

```lua
MiniDeps.add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 
        -- You can choose one of the following pickers
        'nvim-telescope/telescope.nvim',
        'ibhagwan/fzf-lua',
        'echasnovski/mini.pick',
		'folke/snacks.nvim',
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

" You can choose one of the following pickers
Plug 'nvim-telescope/telescope.nvim'
Plug 'ibhagwan/fzf-lua'
Plug 'echasnovski/mini.pick'
Plog 'folke/snacks.nvim'
```

</details>

<details>
<summary>Native package (without a plugin manager) 📦</summary>

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim
nvim -c 'helptags ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim/doc' -c 'q'
```

</details>

You may need to run `helptags ALL` in Neovim to generate the help tags, if your plugin manager does not do it for you.

### Note for HTML

This plugin supports live-previewing Markdown, AsciiDoc and SVG files without the need to save the file. However, for HTML files, the preview will only be updated when you save the file. 

You can create an autocmd that auto save the file when you leave insert mode.

```lua
--- Lua
vim.o.autowriteall = true
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged', 'TextChangedP' }, {
    pattern = '*', callback = function()
        vim.cmd('silent! write')
    end
})
```

```vim
" Vimscript
set autowriteall
autocmd InsertLeavePre,TextChanged,TextChangedP * silent! write
```

# Configuration, usage, FAQ

You can configure this plugin by passing a table to the Lua function
```lua
require('livepreview.config').set()
```

See [`:h livepreview`](./doc/livepreview.txt) for all configurations options, as well as usage and FAQ.

# Contributing :handshake:
 
Since this is a young project, there should be a lot of rooms for improvements. If you would like to contribute to this project, please feel free to open an issue or a pull request.

# Roadmap :rocket:

See [TODO](https://github.com/brianhuster/live-preview.nvim/milestone/1)

# Acknowledgements 🙏

* [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) and [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) for the idea inspiration
* [glacambre/firenvim](https://github.com/glacambre/firenvim) for the sha1 function reference
* [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css) CSS style for Markdown files
* [markdown-it/markdown-it](https://github.com/markdown-it/markdown-it) for parsing Markdown files
* [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js) for parsing AsciiDoc files
* [KaTeX](https://github.com/KaTeX/KaTeX) for rendering math equations
* [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) for rendering diagrams
* [digitalmoksha/markdown-it-inject-linenumbers](https://github.com/digitalmoksha/markdown-it-inject-linenumbers) : A markdown-it plugin for injecting line numbers into html output

# Buy me a coffee ☕

Maintaining this project takes time and effort, especially as I am a student now. If you find this project helpful, please consider supporting me :>

<a href="https://paypal.me/brianphambinhan">
    <img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_111x69.jpg" alt="Paypal" style="height: 69px;">
</a>
<a href="https://img.vietqr.io/image/mb-9704229209586831984-print.png?addInfo=Donate%20for%20livepreview%20plugin%20nvim&accountName=PHAM%20BINH%20AN">
    <img src="https://github.com/user-attachments/assets/f28049dc-ce7c-4975-a85e-be36612fd061" alt="VietQR" style="height: 85px;">
</a>

# Alternatives

See [Wiki](https://github.com/brianhuster/live-preview.nvim/wiki/Alternatives-to-live%E2%80%90preview.nvim) for alternatives to live-preview.nvim
