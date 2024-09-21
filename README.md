# live-preview.nvim

A plugin for Neovim that allows you to view Markdown, HTML (along with CSS, JavaScript) and AsciiDoc files in a web browser with live updates. No external dependencies or runtime are required, since the backend is fully written in Lua and Neovim's built-in functions

> You can read this README in [Tiếng Việt](README.vi.md)

## Demo video

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## Requirements

- Neovim 0.10 or newer
- A web browser

## Installation

You can install the plugin using your favorite plugin manager. Here are some examples:

### Using lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- Not required, but recomended for autosaving
    }
})
```

### Using vim-plug
```vim
Plug 'brianhuster/live-preview.nvim'
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
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

## Contributing

Since this is a young project, there should be a lot of rooms for improvements. If you would like to contribute to this project, please feel free to open an issue or a pull request.


