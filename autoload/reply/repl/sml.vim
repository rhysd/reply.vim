let s:repl = reply#repl#base('sml')

function! s:repl.extract_input_from_terminal_buf(lines) abort
    let input = []
    for line in a:lines
        if line !~# '^[=-] '
            continue
        endif
        let line = substitute(line[2:], '\s*;;\s*$', '', '')
        if line ==# ''
            continue
        endif
        let input += [line]
    endfor
    return input
endfunction
function! reply#repl#sml#new() abort
    return s:repl
endfunction
