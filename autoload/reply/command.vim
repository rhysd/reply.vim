let s:sfile = expand('<sfile>')
let s:path_sep = has('win32') ? '\' : '/'

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
        let globpath = fnamemodify(s:sfile, ':p:h') . s:path_sep . 'repl' . s:path_sep . '*.vim'
        let s:repl_names_cache = map(glob(globpath, 1, 1), {_, p -> substitute(matchstr(p, '\h\w*\ze\.vim$'), '_', '-', 'g')})
    endif
    return s:repl_names_cache
endfunction

function! s:not_supported() abort
    if !has('nvim') && (v:version >= 801 || v:version == 800 && has('patch803'))
        return 0
    endif
    call reply#error('This version is not supported. reply.vim requires Vim 8.0.803 or later')
    return 1
endfunction

function! reply#command#start(args, bang, has_range, start, last) abort
    if s:not_supported()
        return
    endif

    let name = get(a:args, 0, '')

    if len(a:args) >= 2
        let cmdopts = a:args[1 :]
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

    if a:has_range && bufnr != bufnr('%')
        wincmd p
    endif
endfunction

function! reply#command#completion_start(arglead, cmdline, cursorpos) abort
    let tokens = split(a:cmdline, '\s\+')
    if len(tokens) > 2 || len(tokens) == 2 && a:cmdline =~# '\s$'
        return []
    endif

    return filter(copy(s:repl_names()), {_, n -> stridx(n, a:arglead) == 0})
endfunction

function! reply#command#stop(bang) abort
    if s:not_supported()
        return
    endif

    let repls = reply#lifecycle#running_repls()
    if a:bang
        for r in copy(repls)
            if r.running
                call r.stop()
            endif
        endfor
    else
        if empty(repls)
            call reply#echo('No REPL is running')
            return
        endif

        let r = repls[-1]
        if !r.running
            call reply#echo("REPL '%s' is not running", r.name)
            return
        endif

        call r.stop()
    endif
endfunction

function! reply#command#send(str, line_start, line_end) abort
    if s:not_supported()
        return
    endif

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

    if !r.running
        call reply#error("Cannot send text to REPL since '%s' is no longer running", r.name)
        return
    endif

    try
        call r.send_string(str)
    catch /^reply\.vim: /
    endtry
endfunction

function! reply#command#list() abort
    if s:not_supported()
        return
    endif

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

function! reply#command#recv() abort
    if s:not_supported()
        return
    endif

    let bufnr = bufnr('%')
    try
        let repl = reply#lifecycle#repl_for_buf(bufnr)
    catch /^reply\.vim: /
        return
    endtry
    if repl is v:null
        call reply#error('No REPL related to buffer #%d was found', bufnr)
        return
    endif

    try
        let exprs = repl.extract_user_input()
    catch /^reply\.vim: /
        return
    endtry

    " Expression may contain newlines. Separate them into lines.
    let output = []
    for expr in exprs
        let output += split(expr, "\n")
    endfor
    call append('.', output)
endfunction
