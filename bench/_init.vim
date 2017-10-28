packadd! vital.vim
packadd! underscore.vim
packadd! vim-benchmark
let s:root = expand('%:p:h:h')
execute 'set runtimepath+=' . s:root

let s:V = vital#of('vital')
" ramda
let s:Ramda = s:V.import('Ramda')
let g:R = s:Ramda.new()

" underscore
let s:Underscore = s:V.import('Underscore')
let g:_ = s:Underscore.import()
