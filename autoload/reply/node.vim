" Helpers for node.js tools

function! reply#node#find_npm_executable(bin) abort
    let node_modules = finddir('node_modules', ';')
    if node_modules ==# ''
        return ''
    endif
    let executable = printf('%s%s.bin%s%s', fnamemodify(node_modules, ':p'), s:path_sep, s:path_sep, a:bin)
    if !filereadable(executable)
        return ''
    endif
    return executable
endfunction

function! reply#node#extract_exprs_from_lines(lines) abort
    let exprs = []
    let continuing = v:false
    for idx in range(len(a:lines))
        let line = a:lines[idx]
        if stridx(line, '> ') == 0
            " Strip '> '
            let e = line[2 :]
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
