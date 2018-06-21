function! reply#repl#erl#new() abort
    return reply#repl#base('erl', {
        \   'prompt_start' : '^\d\+> ',
        \   'prompt_continue' : v:null,
        \ })
endfunction
