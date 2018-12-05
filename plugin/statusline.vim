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
    autocmd BufUnload,TextChanged * call statusline#UpdateOnce()
    autocmd SessionLoadPost * call statusline#UpdateColor()
augroup END

nmap <silent> <C-p> :call statusline#lintinfo#Jump('prev', 1)<cr>
nmap <silent> <C-n> :call statusline#lintinfo#Jump('next', 1)<cr>
nmap <silent> <leader>tw :call statusline#whitespace#TrimWhitespace()<cr>

let &cpo = s:save_cpo
unlet s:save_cpo
