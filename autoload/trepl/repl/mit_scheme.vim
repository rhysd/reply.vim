let s:repl = trepl#repl#base({'name' : 'mit-scheme'})

function! s:repl.executable() abort
    return self.get_var('executable', 'mit-scheme')
endfunction

function! trepl#repl#mit_scheme#new() abort
    return deepcopy(s:repl)
endfunction
