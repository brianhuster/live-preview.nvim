### Breaking changes
- Default configuration : Now the plugin will use `:pwd` as the server root directory by default. See `dynamic_root` below
- Checkhealth : The plugin no longer check default open command (like `xdg-open`, `open`, `start`,...) in the checkhealth as the plugin now uses `vim.ui.open()` to open default browser. Visit Neovim repository for more about this function.

### New features
- New config option : `dynamic_root` (defaut : false) : If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:pwd`).
- Checkhealth : 
    - **Server and process** : check if the server is running, and its root directory. It can also check if the port is being used by another process and tell you its PID and process name.
    - **User config** : You can check your live-preview.nvim config right in `checkhealth`, without going to your Nvim config file

**⚠️ Important Notice:** You should clear the cache of the browser after updating to ensure the plugin works correctly. 
