function! reply#repl#python3#new() abort
    return reply#repl#base('python3', {
        \   'prompt_start' : '^>>> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
