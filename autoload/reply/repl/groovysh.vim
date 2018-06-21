function! reply#repl#groovysh#new() abort
    return reply#repl#base('groovysh', {
        \   'prompt_start' : '^groovy:000> ',
        \   'prompt_continue' : '^groovy:\%(\d\+\)> ',
        \ })
endfunction
