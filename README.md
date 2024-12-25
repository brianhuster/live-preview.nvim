# Introduction :wave:

[![LuaRocks](https://img.shields.io/luarocks/v/brianhuster/live-preview.nvim?logo=lua&color=purple)](https://luarocks.org/modules/brianhuster/live-preview.nvim)

live-preview.nvim is a plugin for Neovim that allows you to view [Markdown](https://en.wikipedia.org/wiki/Markdown), [HTML](https://en.wikipedia.org/wiki/HTML) (along with CSS, JavaScript), [AsciiDoc](https://asciidoc.org/) and [svg](https://en.wikipedia.org/wiki/SVG) files in a web browser with live updates. No external dependencies or runtime like NodeJS or Python are required, since the backend is fully written in Lua and Neovim's built-in functions.

# Features :sparkles:
 
* Supports markdown, HTML (with reference to CSS, JS), svg and AsciiDoc files 📄
* Support Katex for rendering math equations in markdown and AsciiDoc files 🧮
* Supports mermaid for rendering diagrams in markdown files 🖼️
* Syntax highlighting for code blocks in Markdown and AsciiDoc 🖍️
* Supports sync scrolling in the browser as you scroll in the Markdown files in Neovim. (You need to enable `sync_scroll` in [setup](#setup). This feature should be used with [brianhuster/autosave.nvim](https://github.com/brianhuster/autosave.nvim)) 🔄
* Integration with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 🔭, [`fzf-lua`](https://github.com/ibhagwan/fzf-lua) and [`mini.pick`](https://github.com/echasnovski/mini.pick) for opening files to preview 📂

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
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {
            'brianhuster/autosave.nvim',  -- Not required, but recomended for autosaving and sync scrolling

            -- You can choose one of the following pickers
            'nvim-telescope/telescope.nvim',
            'ibhagwan/fzf-lua',
            'echasnovski/mini.pick',
        },
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
        'brianhuster/autosave.nvim',  -- Not required, but recomended for autosaving and sync scrolling

        -- You can choose one of the following pickers
        'nvim-telescope/telescope.nvim',
        'ibhagwan/fzf-lua',
        'echasnovski/mini.pick',
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
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving

" You can choose one of the following pickers
Plug 'nvim-telescope/telescope.nvim'
Plug 'ibhagwan/fzf-lua'
Plug 'echasnovski/mini.pick'
```

</details>

<details>
<summary>Native package (without a plugin manager) 📦</summary>

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim
nvim -c 'helptags ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim/doc' -c 'q'
```

</details>

# Configuration, usage, FAQ

You can configure this plugin by passing a table to the Lua function `require('live-preview.config').setup()`.

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
