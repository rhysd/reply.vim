let s:repl = reply#repl#base('ts-node')

function! s:repl.extract_exprs_from_terminal(lines) abort
    return reply#node#extract_exprs_from_lines(a:lines)
endfunction

function! reply#repl#ts_node#new() abort
    return deepcopy(s:repl)
endfunction
