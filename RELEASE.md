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

> Note: `opts` means the configuration table passed to the function `require('livepreview').setup(opts)`.
