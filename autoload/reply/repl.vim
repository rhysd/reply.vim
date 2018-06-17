let s:base = {}

function! s:base.get_var(name, default) abort
    let v = 'reply_repl_' . self.name . '_' . a:name
    return get(b:, v, get(g:, v, a:default))
endfunction

function! s:base.executable() abort
    return self.get_var('executable', self.name)
endfunction

function! s:base.is_available() abort
    return executable(self.executable())
endfunction

function! s:base.get_command() abort
    return [self.executable()] +
         \ self.get_var('command_options', []) +
         \ get(self.context, 'cmdopts', [])
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
"   cmdopts?: string[];
" }
function! s:base.start(context) abort
    let self.context = a:context
    let self.running = v:false
    let cmd = self.get_command()
    if type(cmd) != v:t_list
        let cmd = [cmd]
    endif
    let bufnr = term_start(cmd, {
        \   'term_name' : 'reply: ' . self.name,
        \   'vertical' : 1,
        \   'term_finish' : 'close',
        \   'exit_cb' : self._on_close,
        \ })
    call reply#log('Start terminal at', bufnr, 'with command', cmd)
    let self.term_bufnr = bufnr
    let self.running = v:true
endfunction

function! s:base.into_terminal_job_mode() abort
    if bufnr('%') ==# self.term_bufnr
        if mode() ==# 't'
            return
        endif
        " Start Terminal-Job mode
        normal! i
        return
    endif

    let winnr = bufwinnr(self.term_bufnr)
    if winnr != -1
        execute winnr . 'wincmd w'
    else
        execute 'vertical sbuffer' self.term_bufnr
    endif

    if mode() ==# 'n'
        " Start Terminal-Job mode
        normal! i
    endif
endfunction

" Note: Precondition: Terminal window must exists
function! s:base.send_string(str) abort
    if !self.running
        throw reply#error("REPL '%s' is not running", self.name)
    endif

    let str = a:str
    if str[-1] !=# "\n"
        let str .= "\n"
    endif
    " Note: Zsh distinguishes <NL> and <CR> and regards <NL> as <C-j>.
    " We always use <CR> as newline character.
    let str = substitute(str, "\n", "\<CR>", 'g')

    " Note: Need to enter Terminal-Job mode for updating the terminal window

    let prev_winnr = winnr()
    call self.into_terminal_job_mode()

    call term_sendkeys(self.term_bufnr, str)
    call reply#log('String was sent to', self.name, ':', str)

    if winnr() != prev_winnr
        execute prev_winnr . 'wincmd w'
    endif
endfunction

function! s:base.stop() abort
    if !self.running
        call reply#echo("REPL '%s' is not running", self.name)
        return
    endif
    " Maybe needed: call term_setkill(a:repl.term_bufnr, 'term')
    if bufexists(self.term_bufnr)
        try
            execute 'bdelete!' self.term_bufnr
        catch /^Vim\%((\a\+)\)\=:E516/
            " When the buffer is already deleted, skip deleting it
        endtry
        call reply#log('Stopped terminal', self.name, 'at', self.term_bufnr)
    else
        call reply#log('Terminal buffer not found for ', self.name, 'at', self.term_bufnr)
    endif
endfunction

" config {
"   name: string;
" }
function! reply#repl#base(config) abort
    if type(a:config) == v:t_string
        let name = a:config
    else
        let name = a:config.name
    endif
    let r = deepcopy(s:base)
    let r.name = name
    call reply#log('Created new REPL instance for', name)
    return r
endfunction
