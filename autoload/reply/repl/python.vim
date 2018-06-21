function! reply#repl#python#new() abort
    return reply#repl#base('python', {
        \   'prompt_start' : '^>>> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
