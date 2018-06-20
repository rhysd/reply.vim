let s:repl = reply#repl#base('python')

function! s:repl.extract_exprs_from_terminal(lines) abort
    let exprs = []
    let continuing = v:false
    for idx in range(len(a:lines))
        let line = a:lines[idx]
        if stridx(line, '>>> ') == 0
            " Strip '> '
            let e = line[4 :]
            if e !=# ''
                let exprs += [e]
            endif
            let continuing = v:true
        elseif stridx(line, '... ') == 0 && continuing
            let exprs += [line[4 :]]
        else
            let continuing = v:false
        endif
    endfor
    return exprs
endfunction

function! reply#repl#python#new() abort
    return deepcopy(s:repl)
endfunction
