if exists("g:livepreview_config")
    lua require("livepreview").setup(vim.g.livepreview_config)
endif

set backupcopy=yes
