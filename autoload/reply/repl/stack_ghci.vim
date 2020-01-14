let s:repl = reply#repl#base('stack ghci')

function! s:repl.executable() abort
  return 'stack'
endfunction

function! s:repl.get_command() abort
    return [self.executable(), 'ghci']
           \+ self.default_cmdopts()
endfunction

" TODO: It's dirty hack but i didn't find other solution
"  I tryed to play with `+ self.get_var('command_options', ['--no-load'])`
"  in the get_command() function but it didn't work because
"  'command_options' always empty!
"
"  It's nessesary to pass flag --no-load (all project files) to `stack ghci`
"  only when no `cmdopts` was typed from command line
"  Otherwise in the command `:Repl stack_ghci %`(stack ghci --no-load file.hs)
"  argument 'file.hs' will be ignored by stack
function! s:repl.default_cmdopts()
  if get(self.context, 'cmdopts') != []
    return []
  endif
  return ['--no-load']
endfunction

function! s:repl.is_available() abort
  return executable(self.executable()) && filereadable('./stack.yaml')
endfunction

function! reply#repl#stack_ghci#new() abort
    return deepcopy(s:repl)
endfunction
