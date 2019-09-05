" Helpers for node.js tools

let s:path_sep = has('win32') ? '\' : '/'

function! reply#node#find_npm_executable(bin) abort
    let node_modules = finddir('node_modules', ';')
    if node_modules ==# ''
        return ''
    endif
    let executable = printf('%s%s.bin%s%s', fnamemodify(node_modules, ':p'), s:path_sep, s:path_sep, a:bin)
    if !filereadable(executable)
        return ''
    endif
    return executable
endfunction
