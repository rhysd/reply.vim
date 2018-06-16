let s:repl = reply#repl#base('ts-node')

function! s:repl.executable() abort
    return self.get_var('executable', 'ts-node')
endfunction

function! reply#repl#ts_node#new() abort
    return deepcopy(s:repl)
endfunction
