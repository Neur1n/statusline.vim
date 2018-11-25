scriptencoding utf-8

if exists('g:loaded_statusline')
    finish
endif
let g:loaded_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

augroup statusline
    autocmd!
    autocmd WinEnter,BufWinEnter,FileType,SessionLoadPost * call statusline#Update()
    autocmd CursorMoved,BufUnload * call statusline#UpdateOnce()
    autocmd SessionLoadPost * call statusline#UpdateColor()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
