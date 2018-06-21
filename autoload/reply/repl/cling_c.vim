let s:repl = reply#repl#base('cling_c', {
    \   'prompt_start' : '^\[cling]\$ \%(?   \)\@!',
    \   'prompt_continue' : '^\[cling]\$ ?   ',
    \   'ignore_input_pattern' : '^\.',
    \ })

function! s:repl.executable() abort
    return self.get_var('executable', 'cling')
endfunction


function! s:repl.get_command() abort
    return [self.executable(), '-x', 'c'] + self.get_var('command_options', [])
endfunction

function! reply#repl#cling_c#new() abort
    return deepcopy(s:repl)
endfunction
