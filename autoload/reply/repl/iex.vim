function! reply#repl#iex#new() abort
    return reply#repl#base('iex', {
        \   'prompt_start' : '^iex(\d\+)> ',
        \   'prompt_continue' : '^\.\.\.(\d\+)> ',
        \ })
endfunction
