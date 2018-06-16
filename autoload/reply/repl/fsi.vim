let s:repl = reply#repl#base('fsi')

function! s:repl.is_available() abort
    return has('win32') && executable(self.executable())
endfunction

function! reply#repl#fsi#new() abort
    return deepcopy(s:repl)
endfunction
