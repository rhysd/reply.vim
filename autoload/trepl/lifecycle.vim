" Note: utop does not work on Vim 8.1.26

let s:default_repls = {
\   'ruby': ['pry', 'irb'],
\   'python': ['ptpython', 'python'],
\   'ocaml': ['ocaml'],
\   'javascript': ['node'],
\   'typescript': ['ts-node'],
\   'haskell': ['ghci'],
\ }

" TODO: Manage REPL instances

function! trepl#lifecycle#new_repl(name) abort
    try
        " TODO: Manage REPL instances
        return trepl#repl#{a:name}#new()
    catch /^Vim\%((\a\+)\)\=:E117/
        throw trepl#error("REPL '%s' is not defined", a:name)
    endtry
endfunction

function! trepl#lifecycle#new_repl_for(filetype) abort
    let names = get(trepl#var('repls', {}), &filetype, get(s:default_repls, &filetype, []))
    if empty(names)
        throw trepl#error("No REPL is selectable for filetype '%s'. Please read `:help g:trepl_repls`", a:filetype)
    endif
    for name in names
        let repl = trepl#lifecycle#new_repl(name)
        if repl.is_available()
            return repl
        endif
    endfor
    throw trepl#error('No REPL is available. Candidates are %s', names)
endfunction

function! trepl#lifecycle#start_at(bufnr) abort
    let filetype = getbufvar(a:bufnr, '&filetype')
    if filetype ==# ''
        call trepl#error('No filetype is set for buffer %d', a:bufnr)
        return
    endif
    let source = bufname(a:bufnr)
    if !filereadable(source)
        let source = ''
    endif
    try
        let repl = trepl#lifecycle#new_repl_for(filetype)
        call repl.start(source)
    catch /^trepl.vim: /
        " Cleanup
    endtry
endfunction
