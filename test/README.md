### How to Run tests

```
$ cd /path/to/reply.vim
$ git clone https://github.com/thinca/vim-themis.git
$ ./vim-themis/bin/themis test/
```

To run unit tests, [`node`][Node.js] command should be installed in advance.

### How to run guard

Install [guard][] and [guard-shell][] as prerequisites.

```
$ guard -G test/Guardfile
```

[Node.js]: https://nodejs.org/en/
[guard]: https://github.com/guard/guard
[guard-shell]: https://github.com/guard/guard-shell
