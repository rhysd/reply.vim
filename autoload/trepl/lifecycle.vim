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

function! trepl#lifecycle#new(bufnr) abort
    let filetype = getbufvar(a:bufnr, '&filetype')
    if filetype ==# ''
        throw trepl#error('No filetype is set for buffer %d', a:bufnr)
    endif

    let source = bufname(a:bufnr)
    if !filereadable(source)
        let source = ''
    endif

    let repl = trepl#filetype#new_repl(filetype)
    call repl.start({
        \   'source' : source,
        \   'source_bufnr' : a:bufnr,
        \   'on_close' : function('s:did_repl_end'),
        \ })
    call s:did_repl_start(repl)
    return repl
endfunction

function! trepl#lifecycle#all_repls() abort
    return s:repls
endfunction

function! trepl#lifecycle#repl_for_buf(bufnr) abort
    for r in s:repls
        if has_key(r.context, 'source_bufnr') && r.context.source_bufnr == a:bufnr ||
         \ has_key(r, 'term_bufnr') && r.term_bufnr == a:bufnr
            return r
        endif
    endfor
    return v:null
endfunction
