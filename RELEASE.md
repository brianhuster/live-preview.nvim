> Note: `opts` means the configuration table of `live-preview.nvim`.

## Bug fixes
- Files with spaces in their names don't work properly [#254](https://github.com/brianhuster/live-preview.nvim/issues/254)

## Breaking changes
Configuration no longer handles the `opts.cmd` option. The user command used by live-preview.nvim is always `LivePreview`.

## Default changes
`sync_scroll` is now `true` by default (but currently it only works with Markdown)

## New features
- Supports `svg` files.
- New configuration function `require('livepreview.config').set(opts)`. Using this is recommended to avoid loading the whole plugin on startup
The old configuration function `require('livepreview').setup(opts)` is still kept for backwards compatibility, but you should use the new one.

- Since v0.9.2, you can preview Markdown, AsciiDoc and SVG files with live update as you type without the plugin `autosave.nvim`. However, you may still need `autosave.nvim` for HTML files.
- g:loaded_livepreview for disabling the plugin on startup

> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.
