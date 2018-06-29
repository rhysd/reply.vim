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
    if has('nvim') || (v:version >= 801 || v:version == 800 && has('patch803'))
        return 0
    endif
    call reply#error('This version is not supported. reply.vim requires Vim 8.0.803+ or Neovim')
    return 1
endfunction

function! s:move_to_buf(bufnr) abort
    if bufnr('%') == a:bufnr
        return
    endif
    if !bufexists(a:bufnr)
        throw reply#error('Cannot open buffer #%d since it does not exist.', a:bufnr)
    endif
    let winnr = bufwinnr(a:bufnr)
    if winnr != -1
        execute winnr . 'wincmd w'
        return
    endif
    execute 'sbuffer' a:bufnr
endfunction

" {{{ Start
function! s:open_repl(name, cmdopts, always_new, with_text, mods) abort
    call reply#log('Will open REPL terminal for', a:name, 'Configuraiton:', a:cmdopts, a:always_new, a:with_text, a:mods)

    if a:with_text
        let text = s:get_range_text(getpos("'<"), getpos("'>"))
    endif

    let bufnr = bufnr('%')
    if a:always_new || a:cmdopts != []
        let repl = reply#lifecycle#new(bufnr, a:name, a:cmdopts, a:mods)
    else
        let repl = reply#lifecycle#repl_for_buf(bufnr)
        if repl is v:null || repl.running
            let repl = reply#lifecycle#new(bufnr, a:name, a:cmdopts, a:mods)
        else
            call repl.into_terminal_job_mode()
        endif
    endif

    if a:with_text
        call repl.send_string(text)
    endif

    return repl
endfunction

function! reply#command#start(args, bang, mods, has_range, start, last) abort
    if s:not_supported()
        return
    endif

    let name = get(a:args, 0, '')
    let cmdopts = len(a:args) >= 2 ? a:args[1 :] : []
    let bufnr = bufnr('%')
    try
        call s:open_repl(name, cmdopts, a:bang, a:has_range, a:mods)
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
" }}}

" {{{ Stop
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
" }}}

" {{{ Send
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
" }}}

" {{{ List
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
" }}}

" {{{ Recv
function! reply#command#recv(has_range, start_line, end_line) abort
    if s:not_supported()
        return
    endif

    let bufnr = bufnr('%')
    let winnr = winnr()
    try
        let repl = reply#lifecycle#repl_for_buf(bufnr)
    catch /^reply\.vim: /
        return
    endtry
    if repl is v:null
        call reply#error('No REPL related to buffer #%d was found', bufnr)
        return
    endif

    let in_terminal = repl.term_bufnr == bufnr
    if in_terminal && (!has_key(repl.context, 'source_bufnr') || !bufexists(repl.context.source_bufnr))
        call reply#error('Buffer which is related to terminal (bufnr=%d) does not exist', bufnr)
        return
    endif

    let use_range = in_terminal && a:has_range
    try
        let exprs = repl.extract_user_input(use_range ? a:start_line : 1, use_range ? a:end_line : '$')
    catch /^reply\.vim: /
        return
    endtry

    if in_terminal
        call s:move_to_buf(repl.context.source_bufnr)
    endif

    " Expression may contain newlines. Separate them into lines.
    let output = []
    for expr in exprs
        let output += split(expr, "\n")
    endfor
    call append('.', output)
    call reply#log('Appended after current line', line('.'), output)
    execute 'silent' 'normal!' (len(output)+1) . '=='

    if in_terminal
        " Going back to terminal
        execute winnr . 'wincmd w'
    endif
endfunction
"  }}}

" {{{ Auto
function! s:send_text_auto() abort
    if !exists('b:reply__auto_repl')
        call reply#log('b:reply__auto_repl is not found. Giving up :ReplAuto')
        return
    endif
    if !b:reply__auto_repl.running
        call reply#log('REPL', b:reply__auto_repl.name, ' is not running. Giving up :ReplAuto')
        return
    endif

    let newline = line('.')
    let lines = getline(b:reply__auto_prev_line, newline - 1)

    let text = join(lines, "\n")
    if text !~# '^\n*$'
        call reply#log('Automatically send text to buffer', string(text))
        call b:reply__auto_repl.send_string(text)
    endif

    let b:reply__auto_prev_line = newline
endfunction

function! s:cleanup_auto_setup(repl, exitval) abort
    if !has_key(a:repl.context, 'source_bufnr')
        call reply#log('REPL', a:repl.name, 'does not have source_bufnr. Giving up cleanup :ReplAuto setup')
        return
    endif

    let bufnr = a:repl.context.source_bufnr
    if !bufexists(bufnr)
        call reply#log('REPL', a:repl.name, 'buffer', bufnr, 'does not eixst. Giving up cleanup :ReplAuto setup')
        return
    endif

    let b = getbufvar(bufnr, '')
    silent! unlet! b.reply__auto_prev_line
    silent! unlet! b.reply__auto_repl

    execute 'autocmd! plugin-reply-auto CursorMovedI <buffer=' . bufnr . '>'

    call reply#log('Cleanup :ReplAuto setup for buffer', bufnr)
endfunction

function! reply#command#auto(args, bang, mods, has_range, range_begin, range_end) abort
    if s:not_supported()
        return
    endif

    let name = get(a:args, 0, '')
    let cmdopts = len(a:args) > 2 ? a:args[1 :] : []
    let bufnr = bufnr('%')
    try
        let repl = s:open_repl(name, cmdopts, a:bang, a:has_range, a:mods)
    catch /^reply\.vim: /
        return
    endtry

    if bufnr != bufnr('%')
        let w = bufwinnr(bufnr)
        if winnr() != w
            execute w . 'wincmd w'
        endif
    endif

    augroup plugin-reply-auto
        autocmd!
        autocmd CursorMovedI <buffer> if b:reply__auto_prev_line < line('.') | call <SID>send_text_auto() | endif
    augroup END

    call repl.add_hook('on_close', function('s:cleanup_auto_setup'))
    let b:reply__auto_repl = repl
    let b:reply__auto_prev_line = line('$')
    call reply#log('Automatic REPL', repl.name, 'setup for buffer', bufnr)
endfunction
" }}}
