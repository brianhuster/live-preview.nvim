# live-preview.nvim

A Live Preview Plugin for Neovim that allows you to view Markdown or HTML (along with CSS, JavaScript) files in a web browser with live updates.

## Requirements

- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) must be installed.

## Installation

### Using lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        run = 'npm init && npm install && npm install -g nodemon',
    }
})
require("live-preview").setup()
```

### Using packer.nvim

Add the following to your init.lua:

```lua
require('packer').startup(function()
  use {
    'brianhuster/live-preview.nvim',
    run = 'npm install && npm install -g nodemon',
  }
end)
require("live-preview").setup()
```

### Using vim-plug

Add the following to your `init.vim` or `init.lua`:

```vim
call plug#begin('~/.config/nvim/plugged')

Plug 'brianhuster/live-preview.nvim', { 'do': 'npm install && npm install -g nodemon' }

call plug#end()

lua require("live-preview").setup()
```

## Usage

### For default configuration 

To start the live preview, use the command:

`:LivePreview`

This command will open the current Markdown or HTML file in your default web browser and update it live as you write changes to your file.

To stop the live preview server, use the command:

`:StopPreview`

### Configuration

You can customize your commands for starting and stopping the live server by editing the configuration function in your plugin setting inside your plugin manager. Here is how to config so you can use "Lp" and "Sp" instead of LivePreview and StopPreview

Example using Lua : 

```lua
config = function()
    require('live-preview')
    vim.api.nvim_create_user_command('Lp', function() --- Update this line
        require('live-preview').preview_file()
    end, {})
    vim.api.nvim_create_user_command('Sp', function()  --- Update this line
        require('live-preview').stop_preview()
    end, {})
end,
```

Example using VimScript :

```vim
lua require('live-preview')
command! Lp call v:lua.require('live-preview').preview_file() " update this line
command! Sp call v:lua.require('live-preview').stop_preview() " update this line
```


