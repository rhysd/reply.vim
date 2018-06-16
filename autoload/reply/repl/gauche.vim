let s:repl = reply#repl#base('gauche')

function! s:repl.executable() abort
    return self.get_var('executable', 'gosh')
endfunction

function! reply#repl#gauche#new() abort
    return deepcopy(s:repl)
endfunction
