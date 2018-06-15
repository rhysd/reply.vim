" TODO: Support specify name directly
function! trepl#command#start(bang) abort
    try
        call trepl#lifecycle#new(bufnr('%'))
    catch /^trepl\.vim: /
    endtry
    if a:bang
        wincmd p
    endif
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

" TODO: Support visual mode
function! trepl#command#send(str) abort
    let str = a:str
    if str ==# ''
        let str = getline('.')
    endif
    let bufnr = bufnr('%')
    let r = trepl#lifecycle#repl_for_buf(bufnr)
    if r is v:null
        call trepl#error('No REPL related to buffer #%d was found', bufnr)
        return
    endif
    try
        call r.send_string(str)
    catch /^trepl\.vim: /
    endtry
endfunction
