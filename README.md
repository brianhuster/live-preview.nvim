# live-preview.nvim

A Live Preview Plugin for Neovim that allows you to view Markdown or HTML (along with CSS, JavaScript) files in a web browser with live updates.

## Requirements

- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/) must be installed.

## Installation

You can install the plugin using your favorite plugin manager. Here are some examples:

### Using lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        build = 'npm install --frozen-lockfile --production && npm install -g nodemon', --- if you use npm
        -- build = 'yarn install --frozen-lockfile --production && yarn global add nodemon', --- if you use yarn
    }
})
```

### Using vim-plug

Add the following to your Neovim configuration file (`init.vim` or `init.lua`):

```vim
call plug#begin('~/.config/nvim/plugged')

Plug 'brianhuster/live-preview.nvim', { 'do': 'npm install && npm install -g nodemon' } " if you use yarn, replace npm with yarn

call plug#end()
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
})
```

- Using VimScript:

```vim
lua require('live-preview').setup({
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser. Default is 'LivePreview'
        stop = 'StopPreview', -- Command to stop the live preview. Default is 'StopPreview'
    },
    port = 3000, -- Port to run the live preview server on. Default is 3000
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

## License 

This project is licensed under the [MIT License](LICENSE).


