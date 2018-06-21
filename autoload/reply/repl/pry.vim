function! reply#repl#pry#new() abort
    return reply#repl#base('pry', {
        \   'prompt_start' : '^\[\d\+] pry([^)]\+)> ',
        \   'prompt_continue' : '^\[\d\+] pry([^)]\+)\* ',
        \ })
endfunction
