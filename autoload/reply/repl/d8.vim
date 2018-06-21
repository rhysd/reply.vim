function! reply#repl#d8#new() abort
    return reply#repl#base('d8', {
        \   'prompt_start' : '^d8> ',
        \   'prompt_continue' : v:null,
        \ })
endfunction
