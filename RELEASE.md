### New features

- Integrate with telescope.nvim

To use this feature, make sure you have installed [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Then, set `telescope` to `true` in the [configuration table](./README.md#setup) of live-preview.nvim. It will automatically load the `Telescope livepreview` extension when the plugin is set up.

Alternatively, you can load the extension in your Neovim configuration file:

```lua
require('telescope').load_extension('livepreview')
```

Now you can run `:Telescope livepreview` to open live-preview.nvim's Telescope picker.
