let s:repl = reply#repl#base('julia', {
        \   'prompt_start' :    '^julia> ',
        \   'prompt_continue' : '^       \ze\S',
        \ })

function! s:repl.executable() abort
    let exe = self.get_var('executable', 'julia')
    if  has('mac') && !executable(exe)
        " Julia is distributed in .app format. It may be installed in
        " Applications directory and executable is put in it.
        let paths = glob('/Applications/Julia-*.app/Contents/Resources/julia/bin/julia', 1, 1)
        if !empty(paths) && executable(paths[0])
            let exe = paths[0]
        endif
    endif
    return exe
endfunction

function! reply#repl#julia#new() abort
    return deepcopy(s:repl)
endfunction
