let s:repl = reply#repl#base('ghci')

function! s:repl.extract_input_from_terminal_buf(lines) abort
    let input = []
    for line in a:lines
        let prompt = matchstr(line, '^\%(Prelude\|\*[[:alnum:]_.]\+\)\%( [[:alnum:]_.]\+\)\=[>|] ')
        if prompt ==# ''
            continue
        endif
        let expr = line[len(prompt) :]
        if expr ==# ''
            continue
        endif
        let module = matchstr(expr, '^:m\s\+\zs.\+$')
        if module !=# ''
            let input += ['import ' . module]
            continue
        endif
        if expr[0] ==# ':'
            continue
        endif
        let input += [expr]
    endfor
    return input
endfunction

function! s:repl.get_command() abort
    return self.get_base_command() + self.get_var('command_options', [])
endfunction

functio! s:repl.get_base_command() abort
  let result = [self.executable()]
  if self.executable() == 'stack'
    let result += ['exec', 'ghci']
  endif
  return result
endfunctio

function! s:repl.executable() abort
  if executable('ghci')
    return 'ghci'
  endif
  return 'stack'
endfunction

function! reply#repl#ghci#new() abort
    return deepcopy(s:repl)
endfunction
