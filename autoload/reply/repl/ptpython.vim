function! reply#repl#ptpython#new() abort
    return reply#repl#base('ptpython', {
        \   'prompt_start' : '^\%(>>> \|In \[\d\+\]: \)',
        \   'prompt_continue' : '^\.\.\. ',
        \ })
endfunction
