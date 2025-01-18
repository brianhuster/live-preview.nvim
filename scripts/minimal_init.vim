set rtp+=.
so ~/.config/nvim/vimrc
au InsertLeavePre * if !&modifiable | silent! write | endif
func! MinusMap()
	if &ft !=# 'netrw'
		Ex
	endif
endf
nnoremap - <cmd>call MinusMap()<CR>
