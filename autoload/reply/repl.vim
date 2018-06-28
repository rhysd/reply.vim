let s:base = {}

function! s:base_get_var(name, default) dict abort
    let v = 'reply_repl_' . self.path_name . '_' . a:name
    return get(b:, v, get(g:, v, a:default))
endfunction
let s:base.get_var = function('s:base_get_var')

function! s:base_executable() dict abort
    return self.get_var('executable', self.name)
endfunction
let s:base.executable = function('s:base_executable')

function! s:base_is_available() dict abort
    return executable(self.executable())
endfunction
let s:base.is_available = function('s:base_is_available')

function! s:base_get_command() dict abort
    return [self.executable()] +
         \ self.get_var('command_options', [])
endfunction
let s:base.get_command = function('s:base_get_command')

function! s:base_adjust_win_size() dict abort
    let winnr = winnr()
    let c = self.context
    if has_key(c, 'termwin_max_height') && c.termwin_max_height < winheight(winnr)
        call reply#log('Set terminal window', winnr, 'height to', c.termwin_max_height)
        execute 'resize' c.termwin_max_height
    endif
    if has_key(c, 'termwin_max_width') && c.termwin_max_width < winwidth(winnr)
        call reply#log('Set terminal window', winnr, 'width to', c.termwin_max_width)
        execute 'vertical' 'resize' c.termwin_max_width
    endif
endfunction
let s:base.adjust_win_size = function('s:base_adjust_win_size')

" Note: 3rd argument is for Neovim
function! s:base__on_exit(channel, exitval, ...) dict abort
    call reply#log('exit_cb callback with status', a:exitval, 'for', self.name)

    if has_key(self.context, 'on_close')
        call self.context.on_close(self, a:exitval)
    endif

    if has_key(self, 'hooks') && has_key(self.hooks, 'on_close')
        for F in self.hooks.on_close
            call F(self, a:exitval)
        endfor
    endif

    if a:exitval == -1
        " https://github.com/vim/vim/blob/f9c3883b11b33f0c548df5e949ba59fde74d3e7b/src/os_unix.c#L5759
        call reply#log(self.name, 'terminated by signal')
    elseif a:exitval != 0
        call reply#error("REPL '%s' exited with status %d", self.name, a:exitval)
    endif

    if self.running
        call self.stop()
    endif

    unlet self.term_bufnr
endfunction
let s:base._on_exit = function('s:base__on_exit')

function! s:base_open_term(cmd) dict abort
    if has('nvim')
        if has_key(self.context, 'mods') && self.context.mods !=# ''
            execute self.context.mods . ' new'
        else
            execute 'vnew'
        endif

        call reply#log('Will start terminal with command', a:cmd)

        " Use function() to bind self to _on_exit. Otherwise, job on
        " Neovim calls the callback with its options dict as receiver.
        let ret = termopen(a:cmd, {'on_exit' : function(self._on_exit, [], self)})
        if ret == 0
            throw reply#errror('Invalid argument for command %s', string(a:cmd))
        elseif ret == -1
            throw reply#errror('Command for REPL %s is not executable: %s', self.name, string(a:cmd))
        endif
        startinsert

        let b:term_title = 'reply: ' . self.name

        let bufnr = bufnr('%')
        call reply#log('Started terminal at', bufnr, 'on Neovim')
        let self.term_bufnr = bufnr
    else
        let options = {
            \   'term_name' : 'reply: ' . self.name,
            \   'term_finish' : 'open',
            \ }
        if has_key(self.context, 'mods') && self.context.mods !=# ''
            let options.term_opencmd = self.context.mods . ' sbuffer %d'
        else
            " If no <mods> command is specified, splitting vertically is default
            let options.vertical = 1
        endif

        call reply#log('Will start terminal with command', a:cmd, 'and with options', options)

        " Set callbacks after logging to avoid mess up it
        let options.exit_cb = self._on_exit

        let bufnr = term_start(a:cmd, options)
        call reply#log('Started terminal at', bufnr, 'on Vim')
        let self.term_bufnr = bufnr
    endif
endfunction
let s:base.open_term = function('s:base_open_term')

" context {
"   source?: string;
"   source_bufnr?: number;
"   cmdopts?: string[];
"   mods?: string;
"   termwin_max_height?: number;
"   termwin_max_width?: number;
"   on_close?: (r: REPL, exitval: number) => void;
" }
function! s:base_start(context) dict abort
    let self.context = a:context
    let self.running = v:false

    if has_key(self.context, 'cmdopts') && has_key(self.context, 'source') && self.context.source !=# ''
        let src = self.context.source
        call map(self.context.cmdopts, {_, o -> o ==# '%' ? src : o})
    endif

    let cmd = self.get_command() + get(self.context, 'cmdopts', [])
    if type(cmd) != v:t_list
        let cmd = [cmd]
    endif

    call self.open_term(cmd)
    call self.adjust_win_size()

    let self.running = v:true
endfunction
let s:base.start = function('s:base_start')

function! s:base_into_terminal() dict abort
    if bufnr('%') ==# self.term_bufnr
        return
    endif

    let winnr = bufwinnr(self.term_bufnr)
    if winnr != -1
        execute winnr . 'wincmd w'
    else
        let mods = has_key(self.context, 'mods') && self.context.mods !=# '' ?
                    \ self.context.mods : 'vertical'
        execute mods 'sbuffer' self.term_bufnr
        call self.adjust_win_size()
    endif
endfunction
let s:base.into_terminal = function('s:base_into_terminal')

function! s:base_into_terminal_job_mode() dict abort
    call self.into_terminal()
    let mode = mode()
    if mode ==# 't'
        return
    endif
    " Start Terminal-Job mode if job is alive
    if mode ==# 'n' && self.running
        normal! i
    endif
endfunction
let s:base.into_terminal_job_mode = function('s:base_into_terminal_job_mode')

" Note: Precondition: Terminal window must exists
function! s:base_send_string(str) dict abort
    if !self.running
        throw reply#error("REPL '%s' is no longer running", self.name)
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

    if has('nvim')
        " Don't need to enter terminal-job mode for sending keys to REPL on Neovim
        call self.into_terminal()
        call jobsend(getbufvar(self.term_bufnr, '&channel'), [str])
    else
        call self.into_terminal_job_mode()
        call term_sendkeys(self.term_bufnr, str)
    endif
    call reply#log('String was sent to', self.name, ':', str)

    if winnr() != prev_winnr
        execute prev_winnr . 'wincmd w'
    endif
endfunction
let s:base.send_string = function('s:base_send_string')

function! s:base_extract_input_from_terminal_buf(lines) dict abort
    if !has_key(self, 'prompt_start') || self.prompt_start is v:null || !has_key(self, 'prompt_continue')
        throw reply#error("REPL '%s' does not support :ReplRecv", self.name)
    endif

    let exprs = []
    let continuing = v:false
    for idx in range(len(a:lines))
        let line = a:lines[idx]

        let s = matchstr(line, self.prompt_start)
        if s !=# ''
            let line = substitute(line[len(s) :], '\s\+$', '', '')
            if has_key(self, 'ignore_input_pattern') && line =~# self.ignore_input_pattern
                continue
            endif
            if line !=# ''
                let exprs += [line]
            endif
            let continuing = v:true
            continue
        endif

        let s = matchstr(line, self.prompt_continue isnot v:null ? self.prompt_continue : self.prompt_start)
        if s !=# ''
            let exprs += [substitute(line[len(s) :], '\s\+$', '', '')]
            continue
        endif

        let continuing = v:false
    endfor

    return exprs
endfunction
let s:base.extract_input_from_terminal_buf = function('s:base_extract_input_from_terminal_buf')

function! s:base_extract_user_input(start_line, end_line) dict abort
    if !bufexists(self.term_bufnr)
        throw reply#error("Terminal buffer #d for REPL '%s' is no longer existing", self.term_bufnr, self.name)
    endif

    let lines = getbufline(self.term_bufnr, a:start_line, a:end_line)
    if lines == [] || lines == ['']
        throw reply#error("Terminal buffer #d for REPL '%s' is empty", self.term_bufnr, self.name)
    endif

    " On Neovim, many empty lines are continued by the bottom of the terminal window
    " e.g. ['> 1 + 1', '2', '> ', '', '', '', '', '', ..., '']
    " Trim trailing empty lines.
    let i = len(lines) - 1
    while i >= 0
        if lines[i] !=# ''
            break
        endif
        let i -= 1
    endwhile
    if i != len(lines) - 1
        let lines = lines[: i]
    endif

    let exprs = self.extract_input_from_terminal_buf(lines)
    call reply#log('Extracted lines from terminal #', self.term_bufnr, exprs)

    return exprs
endfunction
let s:base.extract_user_input = function('s:base_extract_user_input')

function! s:base_stop() dict abort
    if !self.running
        return
    endif

    let self.running = v:false

    " Note: May be needed: call term_setkill(self.term_bufnr, 'term')
    " At least on macOS, it seems that term_setkill(self.term_bufnr, 'term')
    " does not stop the terminal process actually.
    if bufexists(self.term_bufnr)
        try
            execute 'bwipeout!' self.term_bufnr
        catch /^Vim\%((\a\+)\)\=:E517/
            " When the buffer is already wiped out, skip it
        endtry
        call reply#log('Stopped terminal', self.name, 'at', self.term_bufnr)
    else
        call reply#log('Terminal buffer to close is not found for ', self.name, 'at', self.term_bufnr)
    endif
endfunction
let s:base.stop = function('s:base_stop')

function! s:base_add_hook(hook, funcref) dict abort
    if !has_key(self, 'hooks')
        let self.hooks = {}
    endif
    if !has_key(self.hooks, a:hook)
        let self.hooks[a:hook] = [a:funcref]
    else
        let self.hooks[a:hook] += [a:funcref]
    endif
    call reply#log('Hook', a:hook, 'added:', self.hooks[a:hook])
endfunction
let s:base.add_hook = function('s:base_add_hook')

" config {
"   name: string;
" }
function! reply#repl#base(name, ...) abort
    let config = get(a:, 1, {})
    let r = deepcopy(s:base)
    let r.name = a:name
    if has_key(config, 'prompt_start')
        let r.prompt_start = config.prompt_start
    endif
    if has_key(config, 'prompt_continue')
        let r.prompt_continue = config.prompt_continue
    endif
    if has_key(config, 'ignore_input_pattern')
        let r.ignore_input_pattern = config.ignore_input_pattern
    endif
    let r.path_name = substitute(a:name, '-', '_', 'g')
    return r
endfunction
