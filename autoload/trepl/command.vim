" TODO: Support specify name directly
function! trepl#command#start() abort
    try
        call trepl#lifecycle#new(bufnr('%'))
    catch /^trepl\.vim: /
    endtry
endfunction

function! trepl#command#stop(bang) abort
    let repls = trepl#lifecycle#all_repls()
    if a:bang
        for r in copy(repls)
            call r.stop()
        endfor
    else
        if empty(repls)
            call trepl#echo('No REPL is running')
            return
        endif
        call repls[-1].stop()
    endif
endfunction
