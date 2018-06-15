let s:base = {}

function! s:base.get_var(name, default) abort
    let v = 'trepl_repl_' . self.name . '_' . a:name
    return get(b:, v, get(g:, v, a:default))
endfunction

function! s:base.executable() abort
    return self.get_var('executable', self.name)
endfunction

function! s:base.is_available() abort
    return executable(self.executable())
endfunction

function! s:base.get_command() abort
    return [self.executable()]
endfunction

function! s:base._on_close(channel, exitval) abort
    if has_key(self.context, 'on_close')
        call self.context.on_close(self, a:exitval)
    endif

    if has_key(self, 'hooks') && has_key(self, 'on_close')
        call self.hooks.on_close(self, a:exitval)
    endif

    let self.running = v:false
    unlet self.term_bufnr
endfunction

" context {
"   source?: string;
"   bufname?: string;
" }
function! s:base.start(context) abort
    let self.context = a:context
    let self.running = v:false
    let cmd = self.get_command()
    if type(cmd) != v:t_list
        let cmd = [cmd]
    endif
    let bufnr = term_start(cmd, {
        \   'term_name' : 'trepl: ' . self.name,
        \   'vertical' : 1,
        \   'term_finish' : 'close',
        \   'exit_cb' : self._on_close,
        \ })
    call trepl#log('Start terminal at', bufnr, 'with command', cmd)
    let self.term_bufnr = bufnr
    let self.running = v:true
endfunction

" Note: Precondition: Terminal window must exists
function! s:base.send_string(str) abort
    if !self.running
        call trepl#error("REPL '%s' is not running", self.name)
        return
    endif

    let str = a:str
    if str[-1] !=# "\n"
        let str .= "\n"
    endif

    let winnr = bufwinnr(self.term_bufnr)
    if winnr == -1
        call trepl#error("REPL '%s' is open in window (TODO: Open window if closed)", self.name)
        return
    endif
    let prev_winnr = winnr()
    execute winnr . 'wincmd w'
    " TODO: This does not work if the window is not in terminal normal mode
    normal! i

    let job = term_getjob(self.term_bufnr)
    if job is v:null
        throw trepl#error("Job is not found for terminal at buffer #%d", self.term_bufnr)
    endif
    let ch = job_getchannel(job)
    call ch_sendraw(ch, str)

    if winnr() != prev_winnr
        execute prev_winnr . 'wincmd w'
    endif
endfunction

function! s:base.stop() abort
    if !self.running
        call trepl#echo("REPL '%s' is not running", self.name)
        return
    endif
    " Maybe needed: call term_setkill(a:repl.term_bufnr, 'term')
    if bufexists(a:repl.term_bufnr)
        execute 'bdelete!' a:repl.term_bufnr
        call trepl#log('Stopped terminal', a:repl.name, 'at', a:repl.term_bufnr)
    else
        call trepl#log('Terminal buffer not found for ', a:repl.name, 'at', a:repl.term_bufnr)
    endif
endfunction

function! trepl#repl#base(config) abort
    let r = deepcopy(s:base)
    let r.name = a:config.name
    call trepl#log('Created new REPL instance for', a:config.name)
    return r
endfunction
