if (exists('g:loaded_trepl') && g:loaded_trepl) || &cp
    finish
endif

command! -nargs=0 Repl call trepl#lifecycle#start_at(bufnr('%'))
command! -nargs=0 -bang ReplStop call call(<bang>0 ? 'trepl#lifecycle#stop_all' : 'trepl#lifecycle#stop_latest', [])

let g:loaded_trepl = 1
