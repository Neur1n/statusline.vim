scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:spc = ' '
let s:sep = '%=%='
let s:mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'no'  : 'NO',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'VL',
    \ '' : 'VB',
    \ 'r'  : 'Prompt',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ 't': 'TERMINAL',
\ }
" }

"************************************************************************ {Core
let s:startup = 1

function! statusline#Update() abort
    if s:startup
        call s:Construct('active')
        call s:StaticColor()
        call statusline#UpdateColor('n')
        let s:startup = 0
    endif

    let l:winnr = winnr()
    let l:line = (winnr('$') == 1) ? [s:Construct('active')] :
        \ [s:Construct('active'), s:Construct('inactive')]
    for l:w in range(1, winnr('$'))
        call setwinvar(l:w, '&statusline', l:line[l:w!=l:winnr])
        call setwinvar(l:w, 'layout_changed', l:w!=l:winnr)
        call setwinvar(l:w, 'inactive', l:w!=l:winnr)
    endfor
endfunction

function! statusline#UpdateOnce() abort
    if !exists('w:layout_changed') || w:layout_changed
        call statusline#Update()
    endif
endfunction

function! s:Construct(status) abort
    return s:Left(a:status).s:sep.s:Right(a:status).
         \ '%{statusline#UpdateColor()}'
endfunction

function! s:Left(status) abort
    if a:status ==# 'active'
        return s:Mode().s:GitBranch().s:Name().s:Modification().s:Swap()
    elseif a:status ==# 'inactive'
        return s:Name().s:Modification().s:Swap()
    endif
endfunction

function! s:Right(status) abort
    if a:status ==# 'active'
        return s:Tag().'%<'.s:Info().s:Ruler().s:Whitespace().s:Warning().s:Error()
    elseif a:status ==# 'inactive'
        return s:Ruler()
    endif
endfunction
" }

"*********************************************************************** {Parts
function! s:Mode() abort
    return '%#Mode_# %{statusline#Mode()} '
endfunction

function! statusline#Mode() abort
    if &filetype ==# 'help'
        let l:mode = 'help'
    " elseif &filetype ==# 'qf'
    "     let l:mode = 'quickfix'
    elseif &filetype ==# 'startify'
        let l:mode = 'startify'
    elseif &filetype ==# 'vim-plug'
        let l:mode = 'vim-plug'
    else
        let l:mode = get(s:mode_map, mode(), mode())
    endif

    let l:mode .= &paste ? ' | PASTE' : ''
    let l:mode .= &spell ? ' | SPELL' : ''

    return l:mode
endfunction

function! s:GitBranch() abort
    if exists('g:loaded_gitbranch')
        return '%#VCS_#'.(gitbranch#name() ==# '' ? '' : s:spc.'%{gitbranch#name()}')
    else
        return ''
    endif
endfunction

function! s:Name() abort
    return '%#Name_#'.s:spc.'%n:%{expand("%:p:h:t")}/%t'
endfunction

function! s:Modification() abort
    let l:modified = '%m'
    let l:readonly = '%{&readonly ? " \ue0a2 " : ""}'
    return '%#Modification_#'.l:modified.l:readonly
endfunction

function! s:Swap() abort
    " Indicator for WindowSwap plugin.
    if exists('g:loaded_windowswap')
        return '%#Swap_#'.'%{WindowSwap#IsCurrentWindowMarked() ? " WS" : ""}'
    else
        return ''
    endif
endfunction

function! s:Tag() abort
    " Refer to autoload/tagbar.vim, I don't know why it works. :p
    if exists(':Tagbar')
        return '%#Tag_#'.'%{tagbar#currenttag("%s", "", "%f")}'.s:spc
    else
        return ''
endfunction

function! s:Info() abort
    " let l:value = '0x%B'
    " let l:type = '%Y'

    " if &fileencoding ? &fileencoding : &encoding ==# 'utf-8'
    "     let l:encoding = ''
    " else
    let l:encoding = '%{&fileencoding ? &fileencoding : &encoding}'
    " endif

    " if &fileformat ==# 'unix'
    "     let l:fileformat = ''
    " else
    let l:fileformat = '%{&fileformat}'
    " endif

    return '%#Info_#%Y'.'['.l:encoding.':'.l:fileformat.']'
endfunction

function! s:Ruler() abort
    return '%#Ruler_#'.'%4l/%L:%-3v'
endfunction

function! s:Whitespace() abort
    return '%#Whitespace_#'.'%{statusline#whitespace#NextTrailing().info}'
endfunction

function! s:Warning() abort
    return '%#Warning_#'.'%{statusline#lintinfo#WarnCount()}'
endfunction

function! s:Error() abort
    return '%#Error_#'.'%{statusline#lintinfo#ErrorCount()}'
endfunction
" }

"**************************************************************** {Highlighting
let s:palette = statusline#palette#palette()

function! statusline#UpdateColor(...) abort
    for l:w in range(1, winnr('$'))
        if exists('w:inactive') && w:inactive == 1
            call s:InactiveColor()
        else
            let l:mode = a:0 ? a:1 : mode()
            if l:mode =~# '\v(n|no)'
                call s:NormalColor()
            elseif l:mode ==# 'i'
                call s:InsertColor()
            elseif l:mode =~# '\v(v|V|)'
                " elseif s:mode_map[mode()] =~# 'V'
                call s:VisualColor()
            elseif l:mode =~# '\v(r|R)'
                call s:ReplaceColor()
            elseif l:mode ==# 'c'
                call s:CmdlineColor()
            else
                call s:NormalColor()
            endif
        endif
    endfor
    return ''
endfunction

function! s:StaticColor() abort
    if exists('g:loaded_windowswap')
        call s:Highlight('Swap_', s:palette.S_swap[0], s:palette.S_bg[0],
                    \ s:palette.S_swap[1], s:palette.S_bg[1], 'bold')
    endif
    if exists('g:loaded_gitbranch')
        call s:Highlight('VCS_', s:palette.S_vcs[0], s:palette.S_bg[0],
                    \ s:palette.S_vcs[1], s:palette.S_bg[1], 'bold')
    endif
    if exists(':Tagbar')
        call s:Highlight('Tag_', s:palette.S_tag[0], s:palette.S_bg[0],
                    \ s:palette.S_tag[1], s:palette.S_bg[1], 'italic')
    endif
    call s:Highlight('Info_', s:palette.S_info[0], s:palette.S_bg[0],
                \ s:palette.S_info[1], s:palette.S_bg[1], 'NONE')

    call s:Highlight('Whitespace_', s:palette.S_spc[0], s:palette.S_bg[0],
                \ s:palette.S_spc[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Warning_', s:palette.S_warn[0], s:palette.S_bg[0],
                \ s:palette.S_warn[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Error_', s:palette.S_err[0], s:palette.S_bg[0],
                \ s:palette.S_err[1], s:palette.S_bg[1], 'bold')
endfunction

function! s:NormalColor() abort
    call s:Highlight('Mode_', s:palette.S_bg[0], s:palette.N_mode[0],
                \ s:palette.S_bg[1], s:palette.N_mode[1], 'bold')
    call s:Highlight('Name_', s:palette.N_name[0], s:palette.S_bg[0],
                \ s:palette.N_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.N_modi[0], s:palette.S_bg[0],
                \ s:palette.N_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.N_ruler[0], s:palette.S_bg[0],
                \ s:palette.N_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:InsertColor() abort
    call s:Highlight('Mode_', s:palette.S_bg[0], s:palette.I_mode[0],
                \ s:palette.S_bg[1], s:palette.I_mode[1], 'bold')
    call s:Highlight('Name_', s:palette.I_name[0], s:palette.S_bg[0],
                \ s:palette.I_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.I_modi[0], s:palette.S_bg[0],
                \ s:palette.I_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.I_ruler[0], s:palette.S_bg[0],
                \ s:palette.I_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:VisualColor() abort
    call s:Highlight('Mode_', s:palette.S_bg[0], s:palette.V_mode[0],
                \ s:palette.S_bg[1], s:palette.V_mode[1], 'bold')
    call s:Highlight('Name_', s:palette.V_name[0], s:palette.S_bg[0],
                \ s:palette.V_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.V_modi[0], s:palette.S_bg[0],
                \ s:palette.V_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.V_ruler[0], s:palette.S_bg[0],
                \ s:palette.V_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:ReplaceColor() abort
    call s:Highlight('Mode_', s:palette.S_bg[0], s:palette.R_mode[0],
                \ s:palette.S_bg[1], s:palette.R_mode[1], 'bold')
    call s:Highlight('Name_', s:palette.R_name[0], s:palette.S_bg[0],
                \ s:palette.R_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.R_modi[0], s:palette.S_bg[0],
                \ s:palette.R_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.R_ruler[0], s:palette.S_bg[0],
                \ s:palette.R_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:CmdlineColor() abort
    call s:Highlight('Mode_', s:palette.S_bg[0], s:palette.C_mode[0],
                \ s:palette.S_bg[1], s:palette.C_mode[1], 'bold')
    call s:Highlight('Name_', s:palette.C_name[0], s:palette.S_bg[0],
                \ s:palette.C_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.C_modi[0], s:palette.S_bg[0],
                \ s:palette.C_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.C_ruler[0], s:palette.S_bg[0],
                \ s:palette.C_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:InactiveColor() abort
    call s:Highlight('Name_', s:palette.U_name[0], s:palette.S_bg[0],
                \ s:palette.U_name[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Modification_', s:palette.U_modi[0], s:palette.S_bg[0],
                \ s:palette.U_modi[1], s:palette.S_bg[1], 'bold')
    call s:Highlight('Ruler_', s:palette.U_ruler[0], s:palette.S_bg[0],
                \ s:palette.U_ruler[1], s:palette.S_bg[1], 'NONE')
endfunction

function! s:Highlight(group, guifg, guibg, ctermfg, ctermbg, style) abort
    exec printf('hi %s guifg=%s guibg=%s ctermfg=%s ctermbg=%s gui=%s cterm=%s',
              \ a:group, a:guifg, a:guibg, a:ctermfg, a:ctermbg, a:style, a:style)
endfunction
" }

let &cpo = s:save_cpo
unlet s:save_cpo
