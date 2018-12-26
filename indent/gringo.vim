if exists("b:did_indent")
    finish
endif

let b:did_indent = 1

setlocal indentexpr=GetGringoIndent()
setlocal indentkeys+=0=end,0=until
setlocal indentkeys+=<:>,=elif,=except

if exists("s:did_indent")
    finish
endif

let s:did_indent = 1

let s:maxoff = 50	" maximum number of lines to look backwards for ()
let s:keepcpo= &cpo
set cpo&vim

" copied/modified lua.vim
function! GetGringoLuaIndent()
	let prevlnum = prevnonblank(v:lnum - 1)

	if prevlnum == 0
		return 0
	endif

	let ind = indent(prevlnum)
	let prevline = getline(prevlnum)
	let midx = match(prevline, '^\s*\%(if\>\|for\>\|while\>\|repeat\>\|else\>\|elseif\>\|do\>\|then\>\)')
	if midx == -1
		let midx = match(prevline, '{\s*$')
		if midx == -1
			let midx = match(prevline, '\<function\>\s*\%(\k\|[.:]\)\{-}\s*(')
		endif
	endif

	if midx != -1
		if synIDattr(synID(prevlnum, midx + 1, 1), "name") != "luaComment" && prevline !~ '\<end\>\|\<until\>'
			let ind = ind + &shiftwidth
		endif
	endif

	let midx = match(getline(v:lnum), '^\s*\%(end\|else\|until\|}\)')
	if midx != -1 && synIDattr(synID(v:lnum, midx + 1, 1), "name") != "luaComment"
		let ind = ind - &shiftwidth
	endif

	return ind
endfunction

" copied/modified python.vim
function GetGringoPythonIndent(lnum)

  " If this line is explicitly joined: If the previous line was also joined,
  " line it up with that one, otherwise add two 'shiftwidth'
  if getline(a:lnum - 1) =~ '\\$'
    if a:lnum > 1 && getline(a:lnum - 2) =~ '\\$'
      return indent(a:lnum - 1)
    endif
    return indent(a:lnum - 1) + (exists("g:pyindent_continue") ? eval(g:pyindent_continue) : (&sw * 2))
  endif

  " If the start of the line is in a string don't change the indent.
  if has('syntax_items')
	\ && synIDattr(synID(a:lnum, 1, 1), "name") =~ "String$"
    return -1
  endif

  " Search backwards for the previous non-empty line.
  let plnum = prevnonblank(v:lnum - 1)

  if plnum == 0
    " This is the first non-empty line, use zero indent.
    return 0
  endif

  " If the previous line is inside parenthesis, use the indent of the starting
  " line.
  " Trick: use the non-existing "dummy" variable to break out of the loop when
  " going too far back.
  call cursor(plnum, 1)
  let parlnum = searchpair('(\|{\|\[', '', ')\|}\|\]', 'nbW',
	  \ "line('.') < " . (plnum - s:maxoff) . " ? dummy :"
	  \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
	  \ . " =~ '\\(Comment\\|String\\)$'")
  if parlnum > 0
    let plindent = indent(parlnum)
    let plnumstart = parlnum
  else
    let plindent = indent(plnum)
    let plnumstart = plnum
  endif


  " When inside parenthesis: If at the first line below the parenthesis add
  " two 'shiftwidth', otherwise same as previous line.
  " i = (a
  "       + b
  "       + c)
  call cursor(a:lnum, 1)
  let p = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
	  \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
	  \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
	  \ . " =~ '\\(Comment\\|String\\)$'")
  if p > 0
    if p == plnum
      " When the start is inside parenthesis, only indent one 'shiftwidth'.
      let pp = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
	  \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
	  \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
	  \ . " =~ '\\(Comment\\|String\\)$'")
      if pp > 0
	return indent(plnum) + (exists("g:pyindent_nested_paren") ? eval(g:pyindent_nested_paren) : &sw)
      endif
      return indent(plnum) + (exists("g:pyindent_open_paren") ? eval(g:pyindent_open_paren) : (&sw * 2))
    endif
    if plnumstart == p
      return indent(plnum)
    endif
    return plindent
  endif


  " Get the line and remove a trailing comment.
  " Use syntax highlighting attributes when possible.
  let pline = getline(plnum)
  let pline_len = strlen(pline)
  if has('syntax_items')
    " If the last character in the line is a comment, do a binary search for
    " the start of the comment.  synID() is slow, a linear search would take
    " too long on a long line.
    if synIDattr(synID(plnum, pline_len, 1), "name") =~ "Comment$"
      let min = 1
      let max = pline_len
      while min < max
	let col = (min + max) / 2
	if synIDattr(synID(plnum, col, 1), "name") =~ "Comment$"
	  let max = col
	else
	  let min = col + 1
	endif
      endwhile
      let pline = strpart(pline, 0, min - 1)
    endif
  else
    let col = 0
    while col < pline_len
      if pline[col] == '#'
	let pline = strpart(pline, 0, col)
	break
      endif
      let col = col + 1
    endwhile
  endif

  " If the previous line ended with a colon, indent this line
  if pline =~ ':\s*$'
    return plindent + &sw
  endif

  " If the previous line was a stop-execution statement...
  if getline(plnum) =~ '^\s*\(break\|continue\|raise\|return\|pass\)\>'
    " See if the user has already dedented
    if indent(a:lnum) > indent(plnum) - &sw
      " If not, recommend one dedent
      return indent(plnum) - &sw
    endif
    " Otherwise, trust the user
    return -1
  endif

  " If the current line begins with a keyword that lines up with "try"
  if getline(a:lnum) =~ '^\s*\(except\|finally\)\>'
    let lnum = a:lnum - 1
    while lnum >= 1
      if getline(lnum) =~ '^\s*\(try\|except\)\>'
	let ind = indent(lnum)
	if ind >= indent(a:lnum)
	  return -1	" indent is already less than this
	endif
	return ind	" line up with previous try or except
      endif
      let lnum = lnum - 1
    endwhile
    return -1		" no matching "try"!
  endif

  " If the current line begins with a header keyword, dedent
  if getline(a:lnum) =~ '^\s*\(elif\|else\)\>'

    " Unless the previous line was a one-liner
    if getline(plnumstart) =~ '^\s*\(for\|if\|try\)\>'
      return plindent
    endif

    " Or the user has already dedented
    if indent(a:lnum) <= plindent - &sw
      return -1
    endif

    return plindent - &sw
  endif

  " When after a () construct we probably want to go back to the start line.
  " a = (b
  "       + c)
  " here
  if parlnum > 0
    return plindent
  endif

  return -1

endfunction

" copied/modified prolog.vim
function! GetGringoIndent()
	if synIDattr(synstack(line("."), col("."))[0], "name") == "luaCode"
		return GetGringoLuaIndent()
    elseif synIDattr(synstack(line("."), col("."))[0], "name") == "pythonCode"
        return GetGringoPythonIndent(v:lnum)
	endif
    let pnum = prevnonblank(v:lnum - 1)
    if pnum == 0
       return 0
    endif
    let line = getline(v:lnum)
    let pline = getline(pnum)

    let ind = indent(pnum)
    if pline =~ '^\s*%'
		retu ind
    endif
    if pline =~ ':-\s*\(%.*\)\?$'
		let ind = ind + &sw
    elseif pline =~ '\.\s*\(%.*\)\?$'
		let ind = ind - &sw
    endif
    return ind
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

