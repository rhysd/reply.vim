let s:repl = reply#repl#base({'name' : 'cling_objc'})

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
