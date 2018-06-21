function! reply#repl#kotlinc#new() abort
    return reply#repl#base('kotlinc', {
        \   'prompt_start' : '^>>> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
