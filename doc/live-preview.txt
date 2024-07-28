# My Neovim Plugin

## Version
1.0.0

## Description
A brief description of what your plugin does.

## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Credits](#credits)
6. [License](#license)

## Requirements

- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/) must be installed.

## Installation

You can install the `live-preview.nvim` using your favorite plugin manager.

### Using lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        run = 'npm init && npm install && npm install -g nodemon', --- if you use npm
        -- run = 'yarn init && yarn install && yarn global add nodemon', --- if you use yarn
    }
})
```

### Using packer.nvim

Add the following to your init.lua:

```lua
require('packer').startup(function()
    use {
        'brianhuster/live-preview.nvim',
        run = 'npm install && npm install -g nodemon', --- if you use npm
        -- run = 'yarn install && yarn global add nodemon', --- if you use yarn
    }
end)
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

You can also customize the plugin by passing a table to the `setup` function. Here is an example of how to customize the plugin:

- Using Lua:

```lua
require('live-preview').setup({
    commands = {
        start = 'LivePreview', -- Command to start the live preview server and open the default browser. Default is 'LivePreview'
        stop = 'StopPreview', -- Command to stop the live preview. Default is 'StopPreview'
    },
    port = 3000, -- Port to run the live preview server on. Default is 3000
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

## Credits
This plugin was developed by [Phạm Bình An](https://github.com/brianhuster).

I also acknowledge the following open-source projects and libraries that made this plugin possible:

- [NodeJS](https://github.com/nodejs) and [Nodemon](https://github.com/remy/nodemon) to run the live preview server.
- [Socket.io](https://github.com/socketio/socket.io) to manage real-time communication between the server and the browser.
- [marked](https://github.com/markedjs/marked) to render Markdown files to HTML.

Thank you Neovim community for your support and feedback.

## License 

This project is licensed under the [MIT License](LICENSE).


