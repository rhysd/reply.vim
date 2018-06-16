" Common utilities used throughout reply.vim

function! reply#error(fmt, ...) abort
    let msg = 'reply.vim: ' . a:fmt
    if a:0 != 0
        let msg = call('printf', [msg] + a:000)
    endif
    echohl ErrorMsg | echomsg msg | echohl None
    return msg
endfunction

function! reply#var(name, default) abort
    let v = 'reply_' . a:name
    return get(b:, v, get(g:, v, a:default))
endfunction

function! reply#log(...) abort
    if !reply#var('_enable_debug', 0)
        return
    endif
    echom '[' . strftime('%T') . '] ' . join(map(copy(a:000), 'string(v:val)'), ' ')
endfunction

function! reply#echo(fmt, ...) abort
    let msg = a:fmt
    if a:0 > 0
        let msg = call('printf', [msg] + a:000)
    endif
    echo 'reply.vim: ' . msg
endfunction
