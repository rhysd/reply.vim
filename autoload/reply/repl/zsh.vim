function! reply#repl#zsh#new() abort
    return reply#repl#base('zsh', {
        \   'prompt_start' : reply#var('repl_zsh_prompt_regex', '^[^%]\+% '),
        \   'prompt_continue' : '^\(for\|while\|then\|case\|function\)> ',
        \ })
endfunction
