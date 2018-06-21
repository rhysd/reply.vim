let s:repl = reply#repl#base('irb')

function! s:repl.extract_input_from_terminal_buf(lines) abort
    let exprs = []
    for line in a:lines
        let m = matchlist(line, '^irb([^)]\+):\d\+:\(\d\+\)[*>] \(.*\)$')
        if m == []
            continue
        endif
        let input = m[2]
        if input ==# ''
            continue
        endif
        let nest = m[1]
        if nest > 0
            if input ==# 'end'
                let nest -= 1
            endif
            let input = repeat('  ', nest) . input
        endif
        let exprs += [input]
    endfor
    return exprs
endfunction

function! reply#repl#irb#new() abort
    return deepcopy(s:repl)
endfunction
