function! reply#repl#ts_node#new() abort
    return reply#repl#base('ts-node', {
        \   'prompt_start' : '^> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
