Add the Plugin to Your init.lua:

```lua

-- ~/.config/nvim/init.lua

-- Add plugin configuration
require('markdown_viewer')

-- Define a command to preview Markdown files
vim.api.nvim_create_user_command('LivePreview', function()
  require('markdown_viewer').preview_markdown()
end, {})
```



