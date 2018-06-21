function! reply#repl#ptpython#new() abort
    return reply#repl#base('ptpython', {
        \   'prompt_start' : '^>>> ',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
