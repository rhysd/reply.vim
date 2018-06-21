function! reply#repl#R#new() abort
    return reply#repl#base('R', {
        \   'prompt_start' : '^> ',
        \   'prompt_continue' : '^+ ',
        \ })
endfunction
