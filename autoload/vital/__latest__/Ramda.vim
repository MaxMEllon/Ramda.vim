scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:_R = {}
let s:_r = {}

function! s:_vital_loaded(V) abort
  let s:V = a:V
endfunction

function! s:new() abort
  return deepcopy(s:_R)
endfunction

" R.each {{{
function! s:_R.each(...) abort
  function! E(xs, F) closure
    for x in a:xs
      call a:F(x, index(a:xs, x))
    endfor
  endfunction

  if a:0 is 1
    return { xs -> E(xs, a:1) }
  elseif a:0 is 2
    call E(a:2, a:1)
  else
    throw 'R.each expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction

" Alias: R.each
let s:_R.for_each = s:_R.each
" }}}

" R.map{{{
function! s:_R.map(...) abort
  let WrapedFunc = { k, v -> a:1(v, k) }
  if a:0 is 1
    return { l -> map(l, WrapedFunc) }
  elseif a:0 is 2
    return map(a:2, WrapedFunc)
  else
    throw 'R.map expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.filter{{{
function! s:_R.filter(...) abort
  let WrapedFunc = { k, v -> a:1(v, k) }
  if a:0 is 1
    return { l -> filter(l, WrapedFunc) }
  elseif a:0 is 2
    return filter(a:2, WrapedFunc)
  else
    throw 'R.filter expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.pipe{{{
function! s:_r.pipe(x, xs) abort
  let [F; fs] = a:xs
  let x = a:x
  return len(a:xs) == 1 ? F(x) : F(s:_r.pipe(x, fs))
endfunction

function! s:_R.pipe(...) abort
  let xs = reverse(copy(a:000))
  return { x -> s:_r.pipe(x, xs) }
endfunction
"}}}

" R.all{{{
function! s:_r.all(xs, prev, F)
  let next = a:prev
  for x in a:xs
    let next = next && a:F(x)
    if next is s:_R.F()
      return s:_R.F()
    endif
  endfor
  return next
endfunction

function! s:_R.all(...)
  let F = a:1
  if a:0 is 1
    return { xs -> s:_r.all(xs, s:_R.T(), F) }
  elseif a:0 is 2
    return s:_r.all(a:2, s:_R.T(), F)
  else
    throw 'R.all expected 1~2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.reduce {{{
function! s:_r.reduce(xs, prev, F)
  let prev = a:prev
  for x in a:xs
    let prev = a:F(prev, x)
  endfor
  return prev
endfunction

function! s:_R.reduce(...) abort
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:_R.reduce(F, a:1, xs) }
                \ :  s:_R.reduce(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:_r.reduce(xs, a:2, F) }
  elseif a:0 is 3
    return s:_r.reduce(a:3, a:2, F)
  else
    throw 'R.reduce expected 1~3 args, but actual ' . a:0 . ' args.'
  endif
endfunction

let s:_R.fold = s:_R.reduce
"}}}

" R.reduce_right {{{
function! s:_R.reduce_right(...)
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:_R.reduce_right(F, a:1, xs) }
                \ :  s:_R.reduce_right(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:_r.reduce(recerse(xs), a:2, F) }
  elseif a:0 is 3
    return s:_r.reduce(reverse(a:3), a:2, F)
  else
    throw 'R.reduce_right expected 1~3 args, but actual ' . a:0 . ' args.'
  endif
endfunction

let s:_R.foldr = s:_R.reduce_right
" }}}

" R.find {{{
function! s:_r.find(xs, default, F) abort
  for x in a:xs
    if a:F(x)
      return x
    endif
  endfor
  return a:default
endfunction

function! s:_R.find(...) abort
  let F = a:1
  if a:0 is 1
    return { ... -> a:0 is 1
                \ ? { xs -> s:_R.find(F, a:1, xs) }
                \ : s:_R.find(F, a:1, a:2) }
  elseif a:0 is 2
    return { xs -> s:_r.find(xs, a:2, F) }
  elseif a:0 is 3
    return s:_r.find(a:3, a:2, F)
  else
    throw 'R.find expected 1~3 args, but actual ' . a:0 . 'args.'
  endif
endfunction
" }}}

" R.find_index {{{
function! s:_r.find_index(xs, F) abort
  let j = 0
  for x in a:xs
    if a:F(x)
      return j
    endif
    let j += 1
  endfor
  return -1
endfunction

function! s:_R.find_index(...)
  let F = a:1
  if a:0 is 1
    return { xs -> s:_r.find_index(xs, F) }
  elseif a:0 is 2
    return s:_r.find_index(a:2, F)
  else
    throw 'R.find_index expected 1~2 args, but actual ' . a:0 . 'args.'
  endif
endfunction
" }}}

" R.contains {{{
function! s:_r.contains(xs, val)
  for x in a:xs
    if x ==# a:val
      return s:_R.T()
    endif
  endfor
  return s:_R.F()
endfunction

function! s:_R.contains(...)
  let F = a:1
  if a:0 is 1
    return { xs -> s:_r.contains(xs, a:1) }
  elseif a:0 is 2
    return s:_r.contains(a:2, a:1)
  endif
endfunction

let s:_R.includes = s:_R.contains
" }}}

" R.times {{{
function! s:_R.times(...)
  let F = a:1
  if a:0 is 1
    return { F -> s:_R.map(F, range(a:1)) }
  elseif a:0 is 2
    return s:_R.map(a:2, range(a:1))
  endif
endfunction
"}}}

function! s:_R.T()
  return !0
endfunction

function! s:_R.F()
  return 0
endfunction

function! s:_R.null() abort
  return 9223372036854775806
endfunction

function! s:_R.is_list(x) abort
  return type(a:x) is type([])
endfunction

function! s:_R.is_string(x) abort
  return type(a:x) is type('')
endfunction

" __END__  {{{
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
" }}}
