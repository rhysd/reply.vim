function! reply#repl#node#new() abort
    return reply#repl#base('node', {
        \   'prompt_start' : '^> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
