function! reply#repl#cling#new() abort
    return reply#repl#base('cling', {
        \   'prompt_start' : '^\[cling]\$ \%(?   \)\@!',
        \   'prompt_continue' : '^\[cling]\$ ?   ',
        \   'ignore_input_pattern' : '^\.',
        \ })
endfunction
