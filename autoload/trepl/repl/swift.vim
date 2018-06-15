let s:repl = trepl#repl#base({'name' : 'swift'})

function! s:repl.get_command() abort
    return [self.executable(), '-repl']
endfunction

function! trepl#repl#swift#new() abort
    return deepcopy(s:repl)
endfunction
