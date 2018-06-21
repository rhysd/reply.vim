let s:repl = reply#repl#base('cling_objc', {
    \   'prompt_start' : '^\[cling]\$ \%(?   \)\@!',
    \   'prompt_continue' : '^\[cling]\$ ?   ',
    \   'ignore_input_pattern' : '^\.',
    \ })

function! s:repl.executable() abort
    return self.get_var('executable', 'cling')
endfunction


function! s:repl.get_command() abort
    " Note: By specifying 'objective-c++', Cling will start ObjC++ mode
    let lang = self.get_var('language', 'objective-c')
    return [self.executable(), '-x', lang] + self.get_var('command_options', [])
endfunction

function! reply#repl#cling_objc#new() abort
    return deepcopy(s:repl)
endfunction
