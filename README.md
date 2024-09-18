# live-preview.nvim

A Live Preview Plugin for Neovim that allows you to view Markdown or HTML (along with CSS, JavaScript) files in a web browser with live updates.

## Requirements

- Neovim 0.9 or higher 

## Installation

You can install the plugin using your favorite plugin manager. Here are some examples:

### Using lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
    }
})
```

### Using vim-plug
```vim
Plug 'brianhuster/live-preview.nvim'
```

## Setup

Add the following to your `init.lua`:

```lua
require('live-preview').setup()
```

For `init.vim`:

```vim
lua require('live-preview').setup()
```

You can also customize the plugin by passing a table to the `setup` function. Here is an example of how to customize the plugin:bubbles

- Using Lua:

```lua
require('live-preview').setup({
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser. Default is 'LivePreview'
        stop = 'StopPreview', -- Command to stop the live preview. Default is 'StopPreview'
    },
    port = 5500, -- Port to run the live preview server on. Default is 5500
    browser = "default", -- Browser to open the live preview in. Default is 'default', meaning the default browser of your system will be used
})
```

## Usage

### For default configuration 

To start the live preview, use the command:

`:LivePreview`

This command will open the current Markdown or HTML file in your default web browser and update it live as you write changes to your file.

To stop the live preview server, use the command:

`:StopPreview`

These commands can be changed based on your customization in the `setup` function in your Neovim configuration file. 

Use the command `:help live-preview` to see the help documentation.


