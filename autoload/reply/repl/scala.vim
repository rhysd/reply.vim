function! reply#repl#scala#new() abort
    return reply#repl#base('scala', {
        \   'prompt_start' : '^scala> ',
        \   'prompt_continue' : '^\s\+| ',
        \ })
endfunction
