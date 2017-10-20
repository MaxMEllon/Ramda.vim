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

" R.each {{{
" Usage:
"   R.each(function)
"   R.each(function, list)
"
function! s:R.each(...) abort
  let F = a:1
  let s:E = { xs, F -> execute(join(['for x in xs', 'call F(x, index(xs, x))', 'endfor'], "\n")) }

  if a:0 is 1
    return { xs -> s:E(xs, F) }
  elseif a:0 is 2
    call s:E(a:2, F)
  endif
endfunction

" Alias: R.each
let s:R.for_each = s:R.each
" }}}

" R.map{{{
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
  else
    throw 'R.map expected 2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.filter{{{
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
  else
    throw 'R.filter expected 2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

" R.pipe{{{
" Usage:
"   R.pipe(initalValue, func, func, ...)
"
" Example:
"   R.pipe([1, 2, 3], R.map({ _, v -> v + 1 }, R.filter({ _, v -> 2 < v })))
"
function! s:R.pipe(initalValue, ...) abort
  let Result = a:initalValue
  let j = 0
  while j < a:0
    let Func = a:000[j]
    let Result = l:Func(Result)
    let j += 1
  endwhile
  return Result
endfunction

function! s:R.is_string(x) abort
  if a:0 is 0
    return { x -> s:R.is_string }
  endif
  return type(a:x) is type('')
endfunction
"}}}

" R.all{{{
" Usage:
"   R.all(func)
"   R.all(func, list)
"
" Example:
"   R.all({ x -> 3 == x }, [3, 3, 3, 3])
"     => true
"   let all_equal3 = R.all({ x -> 3 == x })
"   let is_all_equal3 = all_equal3([1, 3, 3, 3])
"     => false
function! s:R.all(...)
  function! s:All(xs, F)
    let result = s:R.T()
    for x in a:xs
      let tmp = a:F(x)
      let result = tmp && result
      if result is s:R.T()
        return result
      endif
    endfor
    return result
  endfunction

  let F = a:1

  if a:0 is 1
    return { xs -> s:All(xs, F) }
  elseif a:0 is 2
    return s:All(a:2, F)
  else
    throw 'R.all expected 2 args, but actual ' . a:0 . ' args.'
  endif
endfunction
"}}}

function! s:R.T()
  return !0
endfunction

function! s:R.F()
  return 1
endfunction

" __END__  {{{
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
" }}}
