" TODO: Manage REPL instances

let s:repls = []

function! s:did_repl_start(repl) abort
    let s:repls += [a:repl]
    call trepl#log(a:repl.name, 'started. curent state:', s:repls)
endfunction

function! s:did_repl_end(repl, exitstatus) abort
    for i in range(len(s:repls))
        if s:repls[i].term_bufnr == a:repl.term_bufnr
            call remove(s:repls, i)
            call trepl#log(a:repl.name, 'closed with exit status', a:exitstatus, '. current state:', s:repls)
            return
        endif
    endfor
    throw trepl#error('BUG: REPL instance is not managed:', a:repl)
endfunction

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
        call repl.start({
            \   'source' : source,
            \   'source_bufnr' : a:bufnr,
            \   'on_close' : function('s:did_repl_end'),
            \ })
        call s:did_repl_start(repl)
    catch /^trepl.vim: /
        " Cleanup
    endtry
endfunction

function! s:stop_repl(repl) abort
    " Maybe needed: call term_setkill(a:repl.term_bufnr, 'term')
    if bufexists(a:repl.term_bufnr)
        execute 'bdelete!' a:repl.term_bufnr
        call trepl#log('Stopped terminal', a:repl.name, 'at', a:repl.term_bufnr)
    else
        call trepl#log('Terminal buffer not found for ', a:repl.name, 'at', a:repl.term_bufnr)
    endif
endfunction

function! trepl#lifecycle#stop_latest() abort
    if empty(s:repls)
        echo 'No REPL is running'
    endif
    call s:stop_repl(s:repls[-1])
endfunction

function! trepl#lifecycle#stop_all() abort
    for r in s:repls
        call s:stop_repl(r)
    endfor
endfunction
