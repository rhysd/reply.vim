let s:repl = reply#repl#base('electron')

" Note available on Windows: https://electronjs.org/docs/tutorial/repl
function! s:repl.is_available() abort
    return !has('win32') && executable(self.executable())
endfunction

function! s:repl.executable() abort
    let config = self.get_var('executable', v:null)
    if config isnot v:null
        return config
    endif
    let local = reply#node#find_npm_executable('electron')
    if local !=# ''
        return local
    endif
    return 'electron'
endfunction

function! s:repl.get_command() abort
    return [self.executable(), '--interactive'] + self.get_var('command_options', [])
endfunction

function! s:repl.extract_exprs_from_terminal(lines) abort
    return reply#node#extract_exprs_from_lines(a:lines)
endfunction

function! reply#repl#electron#new() abort
    return deepcopy(s:repl)
endfunction
