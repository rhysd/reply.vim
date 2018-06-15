function! s:get_range_text(start, last) abort
    let sl = a:start[1]
    let sc = a:start[2] - 1
    let ll = a:last[1]
    let lc = a:last[2] - 1
    if sl > ll || sl == ll && sc > lc
        call trepl#log('Invalid range', a:start, a:last)
        return ''
    endif
    if sl == ll
        return getline(sl)[sc : lc]
    endif
    let lines = [getline(sl)[sc : ]]
    let l = sl + 1
    while l < ll
        let lines += [getline(l)]
        let l += 1
    endwhile
    let lines += [getline(ll)[ : lc]]
    return join(lines, "\n")
endfunction

" TODO: Support specify name directly
function! trepl#command#start(bang, has_range, start, last) abort
    if a:has_range
        let text = s:get_range_text(getpos("'<"), getpos("'>"))
    endif
    try
        let repl = trepl#lifecycle#new(bufnr('%'))
        if a:has_range
            call repl.send_string(text)
        endif
    catch /^trepl\.vim: /
    endtry
    if a:bang || a:has_range
        " TODO: Change meaning of bang to 'always create a new repl'
        " and change default behavior to 'use already running REPL if
        " possible'
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

function! trepl#command#send(str, line_start, line_end) abort
    let str = a:str
    if str ==# ''
        if a:line_start == a:line_end
            let str = getline(a:line_start)
        else
            let str = s:get_range_text(getpos("'<"), getpos("'>"))
        endif
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
