### Breaking changes
The module 'live-preview' has been renamed to 'livepreview'. So please change the config in your `init.vim` or `init.lua` file to use the new module name.

```lua
require("livepreview").setup({
    -- Your config here
})
```
If you use the `lazy.nvim` plugin manager, you can use `opts` instead of `require("livepreview").setup()`.

```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- Not required, but recomended for autosaving
        opts = {
            -- Your config here. You can leave it blank if you want to use the default config
        },
    }
})
```

For init.vim
```
lua << EOF
require("livepreview").setup({
    -- Your config here
})
EOF
```


### New features

Improve performance

Fix some errors with Katex renderings
