if (exists('g:loaded_trepl') && g:loaded_trepl) || &cp
    finish
endif

command! -nargs=0 Repl call trepl#command#start()
command! -nargs=0 -bang ReplStop call trepl#command#stop(<bang>0)

let g:loaded_trepl = 1
