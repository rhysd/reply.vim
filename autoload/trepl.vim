" Common utilities used throughout trepl.vim

function! trepl#error(fmt, ...) abort
    let msg = a:fmt
    if a:0 != 0
        let msg = call('printf', [a:fmt] + a:000)
    endif
    echohl ErrorMsg | echomsg msg | echohl None
    return msg
endfunction

function! trepl#var(name, default) abort
    let v = 'trepl_' . a:name
    return get(b:, v, get(g:, v, a:default))
endfunction

function! trepl#log(...) abort
    if !trepl#var('_enable_debug', 0)
        return
    endif
    echom '[' . strftime('%T') . '] ' . join(map(copy(a:000), 'string(v:val)'), ' ')
endfunction
