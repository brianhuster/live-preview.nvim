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
	@nvim -l scripts/update_readme.lua

.PHONY: test
test:
	@mkdir -p ~/.local/share/nvim/site/plugins/pack/opt
	@ln -s $(PWD) ~/.local/share/nvim/site/plugins/pack/opt/$(PKG_NAME)
	@for test in tests/*.{html,md,adoc}; do \
		echo "Testing $$test"; \
		nvim --headless -c ':e $$test' -c 'LivePreview' -c 'qa'; \
	done
