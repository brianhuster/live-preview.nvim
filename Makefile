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
	@nvim --headless \
		-c "luafile scripts/gen_api_spec.lua" \
		-c "PlenaryBustedDirectory tests/" -c "qa!"

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
