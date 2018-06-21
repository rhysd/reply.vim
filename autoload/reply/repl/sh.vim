function! reply#repl#sh#new() abort
    return reply#repl#base('sh', {
        \   'prompt_start' : '^sh-\d\+\.\d\+\$ ',
        \   'prompt_continue' : '^> ',
        \ })
endfunction
