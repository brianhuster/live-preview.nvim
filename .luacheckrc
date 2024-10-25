-- Rerun tests only if their modification time changed.
cache = true

std = luajit
codes = true

self = false

-- Reference: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
	-- Neovim lua API + luacheck thinks variables like `vim.wo.spell = true` is
	-- invalid when it actually is valid. So we have to display rule `W122`.
	--
	"122",
}

read_globals = { "vim", "bit" }

exclude_files = {}
