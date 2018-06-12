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

" context {
"   source?: string;
"   bufname?: string;
" }
function! s:base.start(context) abort
    let self.context = a:context
    let cmd = self.get_command()
    if type(cmd) != v:t_list
        let cmd = [cmd]
    endif
    let bufnr = term_start(cmd, {
        \   'term_name': 'trepl: ' . self.name,
        \   'vertical': 1,
        \   'term_finish': 'close',
        \ })
    call trepl#log('Start terminal at', bufnr, 'with command', cmd)
    let self.term_bufnr = bufnr
endfunction

" TODO: stop

function! trepl#repl#_base#new(config) abort
    let r = deepcopy(s:base)
    let r.name = a:config.name
    call trepl#log('Created new REPL instance for', a:config.name)
    return r
endfunction
