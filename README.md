Ramda.vim
---
[![Travis CI](https://img.shields.io/travis/MaxMEllon/Ramda.vim/master.svg?style=flat-square&label=Travis%20CI)](https://travis-ci.org/MaxMEllon/Ramda.vim)
[![CircleCI](https://img.shields.io/circleci/project/github/MaxMEllon/Ramda.vim/master.svg?style=flat-square&label=Circle%20CI)](https://circleci.com/gh/MaxMEllon/Ramda.vim)
[![AppVayor](https://img.shields.io/appveyor/ci/gruntjs/grunt/master.svg?style=flat-square&label=AppVeyor)](https://ci.appveyor.com/project/MaxMEllon/ramda-vim)
![Support Vim 8.0.0039 or above](https://img.shields.io/badge/support-Vim%208.0.0039%20or%20above-yellowgreen.svg?style=flat-square)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Doc](https://img.shields.io/badge/doc%20-%3Ah%20vim--fzy--rails-red.svg?style=flat-square)](./doc/Ramda.vim.txt)

About
---

This plugin is inspired by [Underscore.vim](https://github.com/haya14busa/underscore.vim) and [Ramda](http://ramdajs.com``).

Ramda.vim support your functional programming by Vim script.

Installation
---

[Neobundle](https://github.com/Shougo/neobundle.vim) / [Vundle](https://github.com/gmarik/Vundle.vim) / [vim-plug](https://github.com/junegunn/vim-plug)

1. Install [vital.vim](https://github.com/vim-jp/vital.vim) and Ramda.vim with any plugin manager.

```vim
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'MaxMEllon/Ramda.vim'

Plugin 'vim-jp/vital.vim'
Plugin 'MaxMEllon/Ramda.vim'

Plug 'vim-jp/vital.vim'
Plug 'MaxMEllon/Ramda.vim'
```

2. Embed Ramda.vim into your plugin with :Vitalize.

```vim
:Vitalize . --name={plugin_name} Ramda
```

3. Import Ramda.vim in your plugins.

```vim
let s:V = vital#of('vital')
let s:R = s:V.import('Ramda').new()
echo s:R.pipe([1, 2, 3], s:R.map({ _, v -> v + 2 }), s:R.filter({ _, v -> 4 <= v }))
" => [4, 5]
```


Requirements
---
- Vim 8.0.0039 or above. (need `has('lambda')`)

Auther
---
- MaxMEllon (https://github.com/MaxMEllon)

LICENSE
---

- MIT License
