" Note: utop does not work on Vim 8.1.26

let s:default_repls = {
\   'ruby': ['pry', 'irb'],
\   'python': ['ptpython', 'python'],
\   'ocaml': ['ocaml'],
\   'javascript': ['node'],
\   'typescript': ['ts-node'],
\   'haskell': ['ghci'],
\ }

function! trepl#filetype#new_repl(filetype) abort
    let names = get(trepl#var('repls', {}), &filetype, get(s:default_repls, &filetype, []))
    if empty(names)
        throw trepl#error("No REPL is selectable for filetype '%s'. Please read `:help g:trepl_repls`", a:filetype)
    endif

    for name in names
        try
            let repl = trepl#repl#{name}#new()
        catch /^Vim\%((\a\+)\)\=:E117/
            continue
        endtry
        if repl.is_available()
            return repl
        endif
    endfor

    throw trepl#error('No REPL is available. Candidates are %s', names)
endfunction
