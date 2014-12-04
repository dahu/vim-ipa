let s:ipa_to_asc_list = [
      \  'ʌ'   , '^'
      \, 'ɑ:'  , 'a:'
      \, 'æ'   , '@'
      \, 'e'   , 'e'
      \, 'ə'   , '..'
      \, 'ɜ:'  , 'e:'
      \, 'ɪ'   , 'i'
      \, 'i:'  , 'i:'
      \, 'ɒ'   , 'o'
      \, 'ɔ:'  , 'o:'
      \, 'ʊ'   , 'u'
      \, 'u:'  , 'u:'
      \, 'aɪ'  , 'ai'
      \, 'aʊ'  , 'au'
      \, 'eɪ'  , 'ei'
      \, 'oʊ'  , 'Ou'
      \, 'ɔɪ'  , 'oi'
      \, 'eə'  , 'e..'
      \, 'ɪə'  , 'i..'
      \, 'ʊə'  , 'u..'
      \, 'b'   , 'b'
      \, 'd'   , 'd'
      \, 'f'   , 'f'
      \, 'g'   , 'g'
      \, 'h'   , 'h'
      \, 'j'   , 'j'
      \, 'k'   , 'k'
      \, 'l'   , 'l'
      \, 'm'   , 'm'
      \, 'n'   , 'n'
      \, 'ŋ'   , 'N'
      \, 'p'   , 'p'
      \, 'r'   , 'r'
      \, 's'   , 's'
      \, 'ʃ'   , 'S'
      \, 't'   , 't'
      \, 'tʃ'  , 'tS'
      \, 'θ'   , 'th'
      \, 'ð'   , 'TH'
      \, 'v'   , 'v'
      \, 'w'   , 'w'
      \, 'z'   , 'z'
      \, 'ʒ'   , 'Z'
      \, 'dʒ'  , 'dZ'
      \]

let s:ipa_to_asc = {}
let s:asc_to_ipa = {}
let s:ipa_to_asc_list = list#zip(
      \ filter(copy(s:ipa_to_asc_list), 'v:key % 2 == 0'),
      \ filter(copy(s:ipa_to_asc_list), 'v:key % 2 == 1'))
call map(copy(s:ipa_to_asc_list), 'extend(s:ipa_to_asc, {v:val[0] : v:val[1]})')
call map(copy(s:ipa_to_asc), 'extend(s:asc_to_ipa, {v:val : v:key})')

let s:pairs = {
      \  'aɪ'  : 'ai'
      \, 'aʊ'  : 'au'
      \, 'eɪ'  : 'ei'
      \, 'oʊ'  : 'Ou'
      \, 'ɔɪ'  : 'oi'
      \, 'eə'  : 'e..'
      \, 'ɪə'  : 'i..'
      \, 'ʊə'  : 'u..'
      \, 'tʃ'  : 'tS'
      \, 'dʒ'  : 'dZ'
      \, 'ai'  : 'aɪ'
      \, 'au'  : 'aʊ'
      \, 'ei'  : 'eɪ'
      \, 'Ou'  : 'oʊ'
      \, 'oi'  : 'ɔɪ'
      \, 'tS'  : 'tʃ'
      \, 'th'  : 'θ'
      \, 'TH'  : 'ð'
      \, 'dZ'  : 'dʒ'
      \}

function! s:lex(chunk)
  let toks = []
  let elems = split(a:chunk, '\zs')
  let i = 0
  let l = strchars(a:chunk)
  while i < l
    " echom 'i=' . i
    if i < (l-3)
      if elems[i+1] == ':'
        call add(toks, elems[i] . ':')
        let i += 2
      elseif elems[i] == '.' && elems[i+1] == '.'
        call add(toks, elems[i] . '.')
        let i += 2
      elseif has_key(s:pairs, elems[i] . elems[i+1]) != 0
        call add(toks, elems[i] . elems[i+1])
        let i += 2
      else
        call add(toks, elems[i])
        let i += 1
      endif
    else
      call add(toks, elems[i])
      let i += 1
    endif
    " echom 'toks=' . string(toks)
  endwhile
  return toks
endfunction

function! IPA2ASC(str)
  let s = ''
  for c in s:lex(a:str)
    let s .= get(s:ipa_to_asc, c, c)
  endfor
  return s
endfunction

function! ASC2IPA(str)
  let s = ''
  for c in s:lex(a:str)
    let s .= get(s:asc_to_ipa, c, c)
  endfor
  return s
endfunction

function! IPATable()
  echo join(map(copy(s:ipa_to_asc_list), 'v:val[0] . "\t" . v:val[1]'), "\n")
endfunction

command! -nargs=0 IPATable call IPATable()

xnoremap <leader>i2a c<c-r>=IPA2ASC("<c-r>"")<cr><esc>
xnoremap <leader>a2i c<c-r>=ASC2IPA("<c-r>"")<cr><esc>

" Tests {{{1
function! s:test_01()
  let ipa_words = ["kri:ˈeɪt", "ˈfɑ: ˈraʊt", "ˈfɑ: ˈgɒn", "kənˈtrækt"]
  let asc_words = []
  for w in ipa_words
    call add(asc_words, IPA2ASC(w))
  endfor
  let i = 0
  let f = 0
  for w in asc_words
    if ipa_words[i] != ASC2IPA(w)
      echom "Fail: " . w
      let f += 1
    endif
    let i += 1
  endfor
  if f == 0
    echom 'No failures'
  endif
endfunction

function! s:test_02()
  let asc_words = ["kri:ˈeit", "ˈfa: ˈraut", "ˈfa: ˈgon", "k..nˈtr@kt"]
  let ipa_words = []
  for w in asc_words
    call add(ipa_words, ASC2IPA(w))
  endfor
  let i = 0
  let f = 0
  for w in ipa_words
    if asc_words[i] != IPA2ASC(w)
      echom "Fail: " . w
      let f += 1
    endif
    let i += 1
  endfor
  if f == 0
    echom 'No failures'
  endif
endfunction

if expand('%:p') == expand('<sfile>:p')
  call s:test_01()
  call s:test_02()
endif
"}}}

" vim: fdm=marker
