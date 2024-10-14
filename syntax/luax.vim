" Vim syntax file
" Language: luax
" Maintainer: 
" Latest Revision: [Date]

if exists("b:current_syntax")
  finish
endif

" Include Lua syntax
runtime! syntax/lua.vim
unlet b:current_syntax

" Define the region between [[ and ]] as HTML
syntax region luaxHtml start="\[\[" end="\]\]" contains=@HTML

" Include HTML syntax for the region
syntax include @HTML syntax/html.vim

" Set highlighting for luaxHtml
highlight link luaxHtml Special

let b:current_syntax = "luax"

