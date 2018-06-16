let s:repl = reply#repl#base({'name' : 'mit-scheme'})

function! s:repl.executable() abort
    return self.get_var('executable', 'mit-scheme')
endfunction

function! reply#repl#mit_scheme#new() abort
    return deepcopy(s:repl)
endfunction
