function! reply#repl#ptpython#new() abort
  if b:reply_ptpyton_prompt_start ==? "ipython"
    return reply#repl#base('ptpython', {
      \   'prompt_start' : '\vIn [[0-9]*]: ',
      \   'prompt_continue' : '^\.\.\. ',
      \ })
  else
    return reply#repl#base('ptpython', {
      \   'prompt_start' : '^>>> ',
      \   'prompt_continue' : '^\.\.\. ',
      \ })
  endif
endfunction
