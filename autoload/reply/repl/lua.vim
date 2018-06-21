function! reply#repl#lua#new() abort
    return reply#repl#base('lua', {
        \   'prompt_start' : '^> ',
        \   'prompt_continue' : '^>> ',
        \ })
endfunction
