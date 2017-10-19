scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:R = {}

function! s:_vital_loaded(V) abort
  let s:V = a:V
endfunction

function! s:new() abort
  return deepcopy(s:R)
endfunction

" Usage:
"   R.map(function)
"   R.map(function, list)
"
" Example:
"   R.map({ k, v -> v + 1 })
"     => <lambda>({ arr -> map(arr, { k, v -> v + 1 }) })
"   R.map({ k, v -> v + 1 }, [1, 2, 3])
"     => [2, 3, 4]
"
function! s:R.map(...) abort
  if a:0 is 1
    return { l -> map(l, a:1) }
  elseif a:0 is 2
    return map(a:2, a:1)
  endif
endfunction

" Usage:
"   R.filter(function)
"   R.filter(function, list)
"
" Example:
"   R.filter({ k, v -> 0 < v })
"     => <lambda>({ arr -> map(arr, { k, v -> 0 < v }) })
"   R.filter({ k, v -> 0 < v }, [0, 1, 2])
"     => [1, 2]
"
function! s:R.filter(...) abort
  if a:0 is 1
    return { l -> filter(l, a:1) }
  elseif a:0 is 2
    return filter(a:2, a:1)
  endif
endfunction

" Usage:
"   R.pipe(initalValue, func, func, ...)
"
" Example:
"   R.pipe([1, 2, 3], R.map({ _, v -> v + 1 }, R.filter({ _, v -> 2 < v })))
"
function! s:R.pipe(initalValue, ...) abort
  let l:Result = a:initalValue
  let l:j = 0
  while l:j < a:0
    let l:Func = a:000[l:j]
    let l:Result = l:Func(l:Result)
    let l:j += 1
  endwhile
  return l:Result
endfunction

function! s:R.is_string(x) abort
  return type(a:x) is type('')
endfunction

" __END__  {{{
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
" }}}
