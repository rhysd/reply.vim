" TODO: Manage REPL instances

function! trepl#lifecycle#start_at(bufnr) abort
    let filetype = getbufvar(a:bufnr, '&filetype')
    if filetype ==# ''
        call trepl#error('No filetype is set for buffer %d', a:bufnr)
        return
    endif
    let source = bufname(a:bufnr)
    if !filereadable(source)
        let source = ''
    endif
    try
        let repl = trepl#filetype#new_repl(filetype)
        call repl.start(source)
    catch /^trepl.vim: /
        " Cleanup
    endtry
endfunction
