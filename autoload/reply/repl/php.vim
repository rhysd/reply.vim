let s:repl = reply#repl#base('php', {
    \   'prompt_start' : '^php > ',
    \   'prompt_continue' : '^php [({] ',
    \ })

function! s:repl.get_command() abort
    return [self.executable(), '-a'] + self.get_var('command_options', [])
endfunction

function! reply#repl#php#new() abort
    return deepcopy(s:repl)
endfunction
