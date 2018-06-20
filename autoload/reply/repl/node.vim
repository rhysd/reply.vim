let s:repl = reply#repl#base('node')

function! s:repl.extract_exprs_from_terminal(lines) abort
    let exprs = []
    let continuing = v:false
    for idx in range(len(a:lines))
        let line = a:lines[idx]
        if stridx(line, '> ') == 0 && !continuing
            " Strip '> '
            let exprs += [line[2 :]]
            let continuing = v:true
        elseif stridx(line, '... ') == 0 && continuing
            let exprs[-1] .= line[4 :]
        else
            let continuing = v:false
        endif
    endfor
    return exprs
endfunction

function! reply#repl#node#new() abort
    return deepcopy(s:repl)
endfunction
