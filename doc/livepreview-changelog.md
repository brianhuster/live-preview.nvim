# v0.8

> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.

## Breaking changes
- Now the plugin has only one command `opts.cmd` (default: `LivePreview`) instead of two (`opts.commands.start` and `opts.commands.stop`). 
- The command `opts.cmd` has 4 subcommands: `start`, `close`, `pick`, and `help`.
- Takes `opts.cmd = "LivePreview"` as example, to compare with the previous version:
  - `:LivePreview start` is equivalent to `opts.commands.start` (default: `:LivePreview`) of previous version.
  - `:StopPreview close` is equivalent to `opts.commands.stop` (default: `:StopPreview`) of previous version.

## New features
- New configuration options:
  - `opts.picker`: Picker to use for opening files. 3 choices are available: `telescope`, `fzf-lua`, `mini.pick`. If `nil`, the plugin look for the first available picker when you call the `pick` command.
- `LivePreview pick`: Open a picker and select a file to preview. This command works with the pickers `telescope`, `fzf-lua`, and `mini.pick`, as specified in `opts.picker`. If `opts.picker` is `nil`, the plugin will look for the first available picker when you call the `pick` command.
- `LivePreview help`: Show document about each subcommand.

# v0.7

## New features

* Add support for Github emoji in markdown files

# v0.6

## Fix bug
* Fix bug with `dynamic_root = true` option not working [#211](https://github.com/brianhuster/live-preview.nvim/issues/211)

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
