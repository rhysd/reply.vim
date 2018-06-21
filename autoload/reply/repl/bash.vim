function! reply#repl#bash#new() abort
    return reply#repl#base('bash', {
        \   'prompt_start' : reply#var('repl_bash_prompt_regex', '^bash^\d\+\.\d\+\$ '),
        \   'prompt_continue' : '^> ',
        \ })
endfunction
