let s:repl = trepl#repl#base({'name' : 'csi'})

function! s:repl.is_available() abort
    return has('win32') && executable(self.executable())
endfunction

function! trepl#repl#csi#new() abort
    return deepcopy(s:repl)
endfunction
