let s:repl = reply#repl#base('sbt test:console')

function! s:repl.executable() abort
  return "sbt"
endfunction

function! s:repl.is_available() abort
  return executable(self.executable()) && filereadable("./build.sbt")
endfunction

function! s:repl.get_command() abort
    return [self.executable(), 'test:console'] + self.get_var('command_options', [])
endfunction

function! reply#repl#sbt_console#new() abort
    return deepcopy(s:repl)
endfunction
