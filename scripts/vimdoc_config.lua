--- @type table<string,nvim.gen_vimdoc.Config>
--- Generated documentation target, e.g. api.txt
--- @field filename string
---
--- @field section_order string[]
---
--- List of files/directories for gen_vimdoc to read, relative to `base_dir`.
--- @field files string[]
---
--- @field exclude_types? true
---
--- Section name overrides. Key: filename (e.g., vim.c)
--- @field section_name? table<string,string>
---
--- @field fn_name_pat? string
---
--- @field fn_xform? fun(fun: nvim.luacats.parser.fun)
---
--- For generated section names.
--- @field section_fmt fun(name: string): string
---
--- @field helptag_fmt fun(name: string): string
---
--- Per-function helptag.
--- @field fn_helptag_fmt? fun(fun: nvim.luacats.parser.fun): string
---
--- @field append_only? string[]

return {
    lua = {
        filename = 'live-preview.txt',
        section_order = {
            'init.lua',
            'server.lua',
            'utils.lua',
            'health.lua',
            'spec.lua',
        },
        files = {
            'lua/live-preview/',
        },
        fn_xform = function(fun)
            fun.name = fun.name:gsub('M.', '')
        end,
        section_fmt = function(name)
            if name:lower() == 'init' then
                return 'Lua module : require("live-preview")'
            end
            if name:lower() == 'spec' then
                return 'spec = require("live-preview.spec")'
            end
            return string.format('Lua module: require("live-preview.%s")', name:lower())
        end,
        helptag_fmt = function(name)
            if name:lower() == 'init' then
                return 'live-preview'
            end
            return string.format('live-preview.%s', name:lower())
        end,
    }
}
