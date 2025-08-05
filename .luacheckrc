-- Rerun tests only if their modification time changed.
cache = true

std = lua51c
codes = true

self = false

-- Reference: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
	-- Neovim lua API + luacheck thinks variables like `vim.wo.spell = true` is
	-- invalid when it actually is valid. So we have to display rule `W122`.
	--
	"122",
	"211", -- Unused argument
	"212", -- Unused variable
	"611", -- A line consists of nothing but whitespace.
	"612", -- A line contains trailing whitespace.
	"613", -- Trailing whitespace in a string
	"614", -- Trailing whitespace in a comment
	"631", -- Line is too long
}

read_globals = { "vim" }

exclude_files = {}

globals = {
	"LivePreview",
}
