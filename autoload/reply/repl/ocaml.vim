let s:repl = reply#repl#base('ocaml')

function! s:repl.extract_input_from_terminal_buf(lines) abort
    let input = []
    let continuing = v:false
    for line in a:lines
        if !continuing && line !~# '^# '
            continue
        endif
        " Stripg '# ' prompt or '  ' continuing prompt
        let line = line[2:]
        let continuing = v:true
        if line =~# ';;\s*$'
            let line = substitute(line, ';;\s*$', '', '')
            let continuing = v:false
        endif
        if line !=# ''
            let input += [line]
        endif
    endfor
    return input
endfunction

function! reply#repl#ocaml#new() abort
    return s:repl
endfunction
