function! reply#repl#ptpython#new() abort
    return reply#repl#base('ptpython', {
        \   'prompt_start' : '\vIn [[0-9]*]: ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
