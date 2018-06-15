let s:repl = trepl#repl#base({'name' : 'gauche'})

function! s:repl.executable() abort
    return self.get_var('executable', 'gosh')
endfunction

function! trepl#repl#gauche#new() abort
    return deepcopy(s:repl)
endfunction
