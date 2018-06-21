function! reply#repl#go_pry#new() abort
    return reply#repl#base('go-pry', {
        \   'prompt_start' : '^\[\d\+] go-pry> ',
        \   'prompt_continue' : v:null,
        \ })
endfunction
