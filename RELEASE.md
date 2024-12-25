> Note: `opts` means the configuration table of `live-preview.nvim`.

## Bug fixes
- Files with spaces in their names don't work properly [#254](https://github.com/brianhuster/live-preview.nvim/issues/254)

## Breaking changes
Configuration no longer handles the `opts.cmd` option. The user command used by live-preview.nvim is always `LivePreview`.

## New features
- Supports `svg` files.
- New configuration function `require('livepreview.config').set(opts)`. Using this is recommended to avoid loading the whole plugin on startup
The old configuration function `require('livepreview').setup(opts)` is still kept for backwards compatibility, but you should use the new one.

> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.
