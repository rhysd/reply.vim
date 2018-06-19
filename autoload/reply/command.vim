let s:sfile = expand('<sfile>')

function! s:get_range_text(start, last) abort
    let sl = a:start[1]
    let sc = a:start[2] - 1
    let ll = a:last[1]
    let lc = a:last[2] - 1
    if sl > ll || sl == ll && sc > lc
        call reply#log('Invalid range', a:start, a:last)
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

function! s:repl_names() abort
    if !exists('s:repl_names_cache')
        let s:repl_names_cache = map(glob(fnamemodify(s:sfile, ':p:h') . '/repl/*.vim', 1, 1), {_, p -> substitute(matchstr(p, '\h\w*\ze\.vim$'), '_', '-', 'g')})
    endif
    return s:repl_names_cache
endfunction

function! reply#command#start(args, bang, has_range, start, last) abort
    let name = get(a:args, 0, '')
    if name ==# '--'
        let name = ''
    endif

    let dashdash = index(a:args, '--')
    if dashdash >= 0
        let cmdopts = a:args[dashdash+1 :]
    else
        let cmdopts = []
    endif

    if a:has_range
        let text = s:get_range_text(getpos("'<"), getpos("'>"))
    endif

    let bufnr = bufnr('%')
    try
        if a:bang || cmdopts != []
            let repl = reply#lifecycle#new(bufnr, name, cmdopts)
        else
            let repl = reply#lifecycle#repl_for_buf(bufnr)
            if repl isnot v:null
                call repl.into_terminal_job_mode()
            else
                let repl = reply#lifecycle#new(bufnr, name, cmdopts)
            endif
        endif

        if a:has_range
            call repl.send_string(text)
        endif
    catch /^reply\.vim: /
    endtry

    if a:has_range
        wincmd p
    endif
endfunction

function! reply#command#completion_start(arglead, cmdline, cursorpos) abort
    if a:cmdline =~# '^Repl\s\+\h[[:alnum:]-_]*\s\+$'
        " Note: When `:Repl name `, user is going to input REPL command options.
        " So complete '--' for leading user input.
        return ['--']
    endif

    let dashpos = stridx(a:cmdline, '--')
    if dashpos >= 0 && a:cursorpos > dashpos
        " Note: After --, it means command options passed to REPL command
        " execution.
        return []
    endif

    return filter(copy(s:repl_names()), {_, n -> stridx(n, a:arglead) == 0})
endfunction

function! reply#command#stop(bang) abort
    let repls = reply#lifecycle#all_repls()
    if a:bang
        for r in copy(repls)
            call r.stop()
        endfor
    else
        if empty(repls)
            call reply#echo('No REPL is running')
            return
        endif
        call repls[-1].stop()
    endif
endfunction

function! reply#command#send(str, line_start, line_end) abort
    let str = a:str
    if str ==# ''
        if a:line_start == a:line_end
            let str = getline(a:line_start)
        else
            let str = s:get_range_text(getpos("'<"), getpos("'>"))
        endif
    endif
    let bufnr = bufnr('%')
    let r = reply#lifecycle#repl_for_buf(bufnr)
    if r is v:null
        call reply#error('No REPL related to buffer #%d was found', bufnr)
        return
    endif
    try
        call r.send_string(str)
    catch /^reply\.vim: /
    endtry
endfunction

function! reply#command#list() abort
    let repl_names = reply#lifecycle#default_repl_names()
    for filetype in sort(keys(repl_names))
        for name in repl_names[filetype]
            let repl = reply#repl#{name}#new()
            if !repl.is_available()
                echohl Comment | echom printf('%s (%s) [NOT INSTALLED]', name, filetype) | echohl None
                continue
            endif
            echohl Title | echo name | echohl None
            echon printf(' (%s)', filetype)
        endfor
    endfor
endfunction
