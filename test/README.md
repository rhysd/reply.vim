### How to Run tests

```
$ cd /path/to/reply.vim
$ git clone https://github.com/thinca/vim-themis.git
$ ./vim-themis/bin/themis test/
```

### How to run guard

Install [guard](https://github.com/guard/guard) and [guard-shell](https://github.com/guard/guard-shell) as prerequisites.

```
$ guard -G test/Guardfile
```
