scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! statusline#whitespace#NextTrailing() abort
    let l:pos = searchpos('\v(\s+$)', 'cnw')

    if l:pos[0] == 0
        return {'pos': [], 'info': ''}
    else
        return {'pos': l:pos, 'info': 'Ξ'.'('.l:pos[0].')'}
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
