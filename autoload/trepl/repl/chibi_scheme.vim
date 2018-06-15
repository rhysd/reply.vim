let s:repl = trepl#repl#base({'name' : 'chibi-scheme'})

function! s:repl.executable() abort
    return self.get_var('executable', 'chibi-scheme')
endfunction

function! trepl#repl#chibi_scheme#new() abort
    return deepcopy(s:repl)
endfunction
