> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.

## Bug fixes
- Files with spaces in their names don't work properly [#254](https://github.com/brianhuster/live-preview.nvim/issues/254)

## Breaking changes
Configuration no longer handles the `opts.cmd` option. The user command used by live-preview.nvim is always `LivePreview`.

## New features
- Supports `svg` files.

> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.
