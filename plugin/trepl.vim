if (exists('g:loaded_trepl') && g:loaded_trepl) || &cp
    finish
endif

" TODO support <mods>
" TODO support completion
" TODO support 1 argument
command! -nargs=0 -bang -range=0 Repl call trepl#command#start(<bang>0, <count> != 0, <line1>, <line2>)
command! -nargs=0 -bang ReplStop call trepl#command#stop(<bang>0)
command! -nargs=* -range ReplSend call trepl#command#send(<q-args>, <line1>, <line2>)

let g:loaded_trepl = 1
