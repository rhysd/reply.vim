if (exists('g:loaded_reply') && g:loaded_reply) || &cp
    finish
endif

command! -nargs=* -bang -range=0 -complete=customlist,reply#command#completion_start Repl call reply#command#start([<f-args>], <bang>0, <q-mods>, <count> != 0, <line1>, <line2>)
command! -nargs=0 -bang ReplStop call reply#command#stop(<bang>0)
command! -nargs=* -range ReplSend call reply#command#send(<q-args>, <line1>, <line2>)
command! -nargs=0 -bar ReplList call reply#command#list()
command! -nargs=0 -bar -range=0 ReplRecv call reply#command#recv(<count> != 0, <line1>, <line2>)
command! -nargs=* -bang -range=0 -complete=customlist,reply#command#completion_start ReplAuto call reply#command#auto([<f-args>], <bang>0, <q-mods>, <count> != 0, <line1>, <line2>)

let g:loaded_reply = 1
