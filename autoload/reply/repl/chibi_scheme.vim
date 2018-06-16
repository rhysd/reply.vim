let s:repl = reply#repl#base({'name' : 'chibi-scheme'})

function! s:repl.executable() abort
    return self.get_var('executable', 'chibi-scheme')
endfunction

function! reply#repl#chibi_scheme#new() abort
    return deepcopy(s:repl)
endfunction
