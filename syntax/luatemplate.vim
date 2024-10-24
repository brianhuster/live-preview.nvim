" Vim syntax file
" Language: Lua with embedded HTML as [[string]]

if exists("b:current_syntax")
  finish
endif

runtime! syntax/lua.vim
unlet b:current_syntax

syntax include @HTML syntax/template.vim

syntax region luaHTML start="\[\[" end="\]\]" contains=@HTML containedin=luaString,luaComment

highlight default link luaHTML htmlString

let b:current_syntax = "luatemplate"
