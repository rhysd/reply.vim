" Common utilities used throughout reply.vim

let s:path_sep = has('win32') ? '\' : '/'

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

if reply#var('_enable_debug', 0)
    function! reply#log(...) abort
        echom '[' . strftime('%T') . '] ' . join(map(copy(a:000), 'type(v:val) == v:t_string ? v:val : string(v:val)'), ' ')
    endfunction
else
    function! reply#log(...) abort
    endfunction
endif

function! reply#echo(fmt, ...) abort
    let msg = a:fmt
    if a:0 > 0
        let msg = call('printf', [msg] + a:000)
    endif
    echo 'reply.vim: ' . msg
endfunction
