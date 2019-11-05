REPLs play nicely with :terminal on Vim and Neovim
==================================================

[reply.vim][repo] is a Vim and Neovim plugin to make edit buffers play with REPLs nicely.

- REPLs are run in `:terminal` window
- Interaction between edit buffer and REPL
  - Send source from/to edit buffer to/from REPL
  - Automatically evaluate edit buffer with REPL in realtime
- REPL can be selected by filetype with availability
  - e.g. For `ruby` filetype, `pry` is used if available. Otherwise `irb`
- More than 40 REPLs are supported by default
- Your own REPL can be added
- Supports both Vim (8+) and Neovim
- Tested

## Screen casts

Open `node` with `:Repl` command from JavaScript buffer with sending some code from an edit buffer.
`:ReplSend` can send additional text from an edit buffer.

![example to send code](https://github.com/rhysd/ss/blob/master/reply.vim/send.gif?raw=true)

Open `pry` (Ruby REPL) with `:Repl` command and Input some lines in REPL. Finally sends the inputs
to an edit buffer with `:ReplRecv`.

![example to receive code](https://github.com/rhysd/ss/blob/master/reply.vim/recv.gif?raw=true)

Open `node` with `:ReplAuto` and some code edited in an edit buffer are sent to REPL and evaluated
automatically.
This feature is experimental and it may not work with some REPL command.

![example to auto binding](https://github.com/rhysd/ss/blob/master/reply.vim/auto.gif?raw=true)

## Problem This Plugin Solves

REPL is useful to learn/confirm APIs and language features promptly. I usually split a new Tmux pane
and started a new REPL. However, in terms of reuse of input code in REPL, I needed to copy the code
from the Tmux pane to Vim via clipboard or simply to input it again in Vim. I wondered I could
improve the experience to use REPLs while editing some code in Vim.

## Installation

If you use any package manager, please follow its instruction.

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'rhysd/reply.vim', { 'on': ['Repl', 'ReplAuto'] }
```

With [dein.vim](https://github.com/Shougo/dein.vim):

```vim
call dein#add('rhysd/reply.vim', {
            \   'lazy' : 1,
            \   'on_cmd' : ['Repl', 'ReplAuto'],
            \ })
```

With [minpac](https://github.com/k-takata/minpac):

```vim
call minpac#add('rhysd/reply.vim')
```

When you're using Vim's builtin packager, please follow instruction at `:help pack-add`.

## Usage

### Open REPL

- `:Repl`

Without any arguments, it opens REPL for current filetype as a new terminal window with `:terminal`.

- `:Repl {REPL}`

Open REPL specified by name. Supported REPL's names are listed in output of `:ReplList`.

- `:Repl {REPL} {args...}`

Open REPL specified by name with any arguments. Arguments will be passed to underlying command
execution of the REPL.

- `:[range]Repl [{REPL} [{args...}]]`

In visual mode, `:Repl` opens a REPL and sending the selected text to REPL.
It is useful when you want to start a REPL with some code in the edit buffer.

- `:<mods> Repl [{REPL} [{args...}]]`

Specify how to open `:terminal` window. For example, `:botright Repl` opens a terminal window for
REPL by splitting horizontally.

### Send lines from edit buffer to REPL

- `:ReplSend`

Send the current line in edit buffer to REPL running in a terminal window.
This command is available in an edit buffer.

- `:[range]ReplSend`

In visual mode, selected text is sent to REPL running in a terminal window.

### Receive lines from REPL in edit buffer

- `:ReplRecv`

Sends input codes in REPL to edit buffer. This command is available in both a terminal window and
an edit buffer.

- `:[range]ReplRecv`

In visual mode, selected text in REPL is sent to edit buffer. Visual mode support is only available
in a terminal window.

### Close REPL

- `:ReplStop`

It closes the terminal window. It is available in both an edit buffer and a terminal window.
`reply.vim` remembers which REPL terminal window was opened from which edit buffer.

### Check list of REPLs

- `:ReplList`

It shows a list of REPLs and their filetypes with syntax highlights. Unavailable REPLs are colored
with `Comment` highlight group. 

### Bind input to edit buffer with REPL (experimental)

- `:ReplAuto`

It is similar to `:Repl`, but it binds input to the edit buffer with opened REPL. All inputs are
**automatically** sent to REPL and evaluated when you type an enter key in the edit buffer.

It is useful for lazy people who want to write some code with confirming the value. But please be
careful not to break your environment by sending a dangerous code to REPL. This feature is supposed
to be used for learning a new language.

### Mappings

No mapping is defined by default. Please allocate the commands to your favorite keys.

## Customization

### `g:reply_repls` and `b:reply_repls`

- Type: `dict` (`string => list<string | function>`)
- Default value: `{}`

Dictionary from filetype to list of REPL names. The list is candidates to open on the filetype.
For example, following configuration will use only `irb` for `ruby` filetype even if `pry` is
available on your system.

```vim
let g:reply_repls = {
\   'ruby': ['irb']
\ }
```

For filetypes not specified in `g:reply_repls`, `reply.vim` uses default values defined at top of
[autoload/reply/lifecycle.vim](./autoload/reply/lifecycle.vim).

For an element of the list, function value is also available to define your own REPL.

For example, let's say you have your own `mycalc` REPL which shows a prompt `calc> `.

```vim
function! s:define_mycalc_repl() abort
    return reply#repl#base('mycalc', {
        \   'prompt_start' : '^calc> ',
        \   'prompt_continue' : v:null,
        \ })
endfunction

let g:reply_repls = {
\   'text': [function('s:define_mycalc_repl')],
\ }
```

It opens your `mycalc` command by `:Repl` in `text` filetype or `:Repl mycalc`.

Lambda expression is also available to avoid defining functions for each your REPLs.

```vim
let g:reply_repls = {
\   'text': [
\     {-> reply#repl#base('mycalc', {
\       'prompt_start' : '^calc> ',
\       'prompt_continue' : v:null,
\     })}
\   ],
\ }
```

For usage of `reply#repl#base()` function, please read codes for default REPL supports at
[autoload/reply/repl/](./autoload/reply/repl/).

`b:reply_repls` is a buffer-local variable which overwrites `g:reply_repls` locally.

### `g:reply_termwin_max_height` and `g:reply_termwin_max_width`

- Type: `number`
- Default value: undefined

Specify max lines and colmuns of a terminal window opened by `:Repl` and `:ReplAuto`. It is useful
to avoid consuming too wide space by REPL.

`b:reply_termwin_max_height` and `b:reply_termwin_max_width` are buffer-local version of the
variables.


## License

Distributed under [the MIT license](LICENSE).

[repo]: https://github.com/rhysd/reply.vim
