let s:repl = trepl#repl#base({'name' : 'ts-node'})

function! s:repl.executable() abort
    return self.get_var('executable', 'ts-node')
endfunction

function! trepl#repl#ts_node#new() abort
    return deepcopy(s:repl)
endfunction
