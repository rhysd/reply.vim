function! reply#repl#psysh#new() abort
    return reply#repl#base('psysh', {
        \   'prompt_start' : '^>>> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
