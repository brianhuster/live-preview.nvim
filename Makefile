SHELL := /bin/bash

PWD = $(shell pwd)
PKG_NAME = $(shell jq -r '.name' pkg.json)

.PHONY: gendoc
gendoc:
	@echo "Generating vimdoc..."
	@nvim -l scripts/gen_vimdoc.lua
	@echo "Generating help tags..."
	@nvim --headless -c 'helptags doc' -c 'qa'

.PHONY: update_readme
update_readme:
	@echo "Updating README based on pkg.json"
	@nvim --headless -c "luafile scripts/update_readme.lua" -c "qa!"

.PHONY: test
test: 
	@echo "Running functional tests with plenary..."
	@nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa!"

.PHONY: test_basic
test_basic:
	@echo "Running basic tests without plenary (fallback)..."
	@nvim --headless -u tests/minimal_init.lua -c "lua dofile('tests/test_runner.lua')" -c "qa!"

.PHONY: test_html
test_html:
	@nvim --headless -c "e tests/index.html" -c "LivePreview"

.PHONY: test_md
test_md:
	@nvim --headless -c "e tests/test.md" -c "LivePreview"

.PHONY: test_adoc
test_adoc:
	@nvim --headless -c "e tests/test.adoc" -c "LivePreview"

luacheck:
	luacheck lua plugin scripts

stylua:
	stylua lua plugin scripts
