let s:repl = reply#repl#base('csi')

function! s:repl.is_available() abort
    return has('win32') && executable(self.executable())
endfunction

function! reply#repl#csi#new() abort
    return deepcopy(s:repl)
endfunction
