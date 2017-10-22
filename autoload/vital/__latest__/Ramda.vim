scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:R = {}
let s:r = {}

function! s:_vital_loaded(V) abort
  let s:V = a:V
endfunction

function! s:new() abort
  return deepcopy(s:R)
endfunction

" R.each {{{
" Usage:
"   R.each({func})
"     " => <lambda>
"   R.each({func}, {list})
"     " => <list>

function! s:R.each(...) abort
  let F = a:1
  let s:E = { xs, F -> execute(join(['for x in xs', 'call F(x, index(xs, x))', 'endfor'], "\n")) }

  if a:0 is 1
    return { xs -> s:E(xs, F) }
  elseif a:0 is 2
    call s:E(a:2, F)
  else
    throw 'R.each expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction

" Alias: R.each
let s:R.for_each = s:R.each
" }}}

" R.map{{{
" Usage:
"   R.map({func})
"     " => <lambda>
"   R.map({func}, {list})
"     " => <list>

function! s:R.map(...) abort
  if a:0 is 1
    return { l -> map(l, a:1) }
  elseif a:0 is 2
    return map(a:2, a:1)
  else
    throw 'R.map expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.filter{{{
" Usage:
"   R.filter({func})
"     " => <lambda>
"   R.filter({func}, {list})
"     " => <list>

function! s:R.filter(...) abort
  if a:0 is 1
    return { l -> filter(l, a:1) }
  elseif a:0 is 2
    return filter(a:2, a:1)
  else
    throw 'R.filter expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.pipe{{{
" Usage:
"   R.pipe([ {func1}, {func2}, ... ])
"     " => <lambda>

function! s:r.pipe(x, fs) abort
  let [F; fs] = a:fs
  return len(a:fs) is 1 ? F(a:x) : F(s:r.pipe(a:x, fs))
endfunction

function! s:R.pipe(fs) abort
  return { x -> s:r.pipe(x, reverse(a:fs)) }
endfunction
"}}}

" R.all{{{
" Usage:
"   R.all({func})
"     " => <lambda>
"   R.all({func}, {list})
"     " => <bool>
"
function! s:r.all(xs, prev, F) "{{{
  let [x; xs] = a:xs
  let next = a:prev && a:F(x)
  return next is s:R.F() ? s:R.F() : len(a:xs) is 1 ? next : s:r.all(xs, next, a:F)
endfunction
"}}}

function! s:R.all(...)
  let F = a:1
  if a:0 is 1
    return { xs -> s:r.all(xs, s:R.T(), F) }
  elseif a:0 is 2
    return s:r.all(a:2, s:R.T(), F)
  else
    throw 'R.all expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.reduce {{{
" Usage:
"   R.reduce({func})
"     " => <lambda>
"   R.reduce({func}, {val})
"     " => <lambda>
"   R.reduce({func}, {val}, {list})
"     " => {val}
"
function! s:r.reduce(xs, prev, F) "{{{
  let [x; xs] = a:xs
  return len(a:xs) is 1 ? a:F(a:prev, x) : s:r.reduce(xs, a:F(a:prev, x), a:F)
endfunction
"}}}

function! s:R.reduce(...) abort
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:R.reduce(F, a:1, xs) }
                \ :  s:R.reduce(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:r.reduce(xs, a:2, F) }
  elseif a:0 is 3
    return s:r.reduce(a:3, a:2, F)
  else
    throw 'R.reduce expected 1~3 args, but actual ' . a:0 . ' args.'
  endif
endfunction

let s:R.fold = s:R.reduce
"}}}

" R.reduce_right{{{
" Usage:
"   R.reduce({func})
"     " => <lambda>
"   R.reduce({func}, {val})
"     " => <lambda>
"   R.reduce({func}, {val}, {list})
"     " => {val}

function! s:R.reduce_right(...)
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:R.reduce_right(F, a:1, xs) }
                \ :  s:R.reduce_right(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:r.reduce(recerse(xs), a:2, F) }
  elseif a:0 is 3
    return s:r.reduce(reverse(a:3), a:2, F)
  else
    throw 'R.reduce_right expected 1~3 args, but actual ' . a:0 . ' args.'
  endif
endfunction

let s:R.foldr = s:R.reduce_right
"}}}

" R.find{{{
" Usage:
"   R.find({func})
"     " => <lambda>
"   R.find({func}, {val})
"     " => <lambda>
"   R.find({func}, {val}, {list})
"     " => {val}

function! s:r.find(xs, default, F) abort
  let [x; xs] = a:xs
  return a:F(x) is s:R.T() ? x : len(a:xs) is 1 ? a:default : s:r.find(xs, a:default, a:F)
endfunction

function! s:R.find(...) abort
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:R.find(F, a:1, xs) }
                \ : s:R.find(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:r.find(xs, a:2, F) }
  elseif a:0 is 3
    return s:r.find(a:3, a:2, F)
  else
    throw 'R.find expected 1~3 args, but actual ' . a:0 . 'args.'
  endif
endfunction
"}}}

function! s:R.T()
  return !0
endfunction

function! s:R.F()
  return 1
endfunction

function! s:R.null()
  return 9223372036854775806
endfunction

function! s:R.is_string(...) abort
  return type(a:x) is type('')
endfunction

" __END__  {{{
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
" }}}
