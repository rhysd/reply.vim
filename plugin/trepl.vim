if (exists('g:loaded_trepl') && g:loaded_trepl) || &cp
    finish
endif

command! -nargs=0 Repl call trepl#lifecycle#start_at(bufnr('%'))

let g:loaded_trepl = 1
