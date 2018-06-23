function! reply#repl#elm_repl#new() abort
    return reply#repl#base('elm-repl', {
        \   'prompt_start' : '^> ',
        \   'prompt_continue' : '^| ',
        \ })
endfunction
