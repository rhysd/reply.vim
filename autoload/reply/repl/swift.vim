function! reply#repl#swift#new() abort
    return reply#repl#base('swift', {
        \   'prompt_start' : '^\s\+\d\+> ',
        \   'prompt_continue' : '^\s\+\d\+\. ',
        \ })
endfunction
