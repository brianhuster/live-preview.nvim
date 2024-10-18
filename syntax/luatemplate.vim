" Vim syntax file
" Language: Lua with embedded HTML as [[string]]
" Maintainer: Pham Binh An
" Latest Revision: 2024-10-18

if exists("b:current_syntax")
  finish
endif

" Load Lua syntax
runtime! syntax/lua.vim
unlet b:current_syntax

" Define a new syntax cluster for HTML
syntax include @HTML syntax/template.vim

" Define the region for HTML content
syntax region luaHTML start="\[\[" end="\]\]" contains=@HTML containedin=luaString,luaComment

" Link the new region to the HTML highlighting
highlight default link luaHTML htmlString

let b:current_syntax = "luatemplate"
