## 🗑️ Deprecated API
* `require('livepreview').preview_file()`. Use `require('livepreview').live_start()` instead.
* `require('livepreview').stop_preview()`. Use `require('livepreview').live_stop()` instead.


## ✨ New features

### 🔍 Integration with telescope.nvim

To use this feature, make sure you have installed [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Then, set `telescope.autoload` to `true` in the [configuration table](./README.md#setup) of live-preview.nvim. It will automatically load the `Telescope livepreview` extension when the plugin is set up.

Alternatively, you can load the extension in your Neovim configuration file:

```lua
require('telescope').load_extension('livepreview')
```

Now you can run `:Telescope livepreview` to open live-preview.nvim's Telescope picker.

### ⚙️ New configuration options
`autokill` (default: `false` or `v:false`): If true, the plugin will automatically kill other processes running on the same port (except for Neovim) when starting the server.

### File path as optional argument for the command to start server

You can now pass a file path as an argument to the command `:LivePreview` (or whatever you configure) to open that file in the browser. For example, `:LivePreview Documents/file.md`.

### Availability on Luarocks 🪨


Now you can use [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim) to install live-preview.nvim with a single command:

```vim
:Rocks install live-preview.nvim
```
