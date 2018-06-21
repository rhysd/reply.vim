let s:repl = reply#repl#base('icr')

function! s:repl.extract_input_from_terminal_buf(lines) abort
    let input = []
    for line in a:lines
        let prompt = matchstr(line, '^icr(\d\+\.\d\+\.\d\+) > ')
        if prompt ==# ''
            continue
        endif
        let line = substitute(line[len(prompt) :], '\s*$', '', '')
        if line ==# ''
            continue
        endif
        if line =~# '^\s\+end$'
            let line = 'end'
        endif
        let input += [line]
    endfor
    return input
endfunction

function! reply#repl#icr#new() abort
    return deepcopy(s:repl)
endfunction
