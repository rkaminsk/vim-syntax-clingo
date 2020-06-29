if version < 600
   syntax clear
elseif exists("b:current_syntax")
  finish
endif

let b:current_syntax = ''
unlet b:current_syntax
syn include @Lua syntax/lua.vim

let b:current_syntax = ''
unlet b:current_syntax
syn include @Python syntax/python.vim

syn case match

syn match  gringoKeyword    "\*%"
syn match  gringoComment    +%.*+
syn region gringoBlockComment start="%\*" end="\*%"

syn match  gringoError      "#.*"

syn region luaCode          matchgroup=gringoKeyword start="#begin_lua" keepend end="#end_lua" contains=@Lua
syn region luaCode          matchgroup=gringoKeyword start="#script[ ]*([ ]*lua[ ]*)" keepend end="#end" contains=@Lua
syn region pythonCode       matchgroup=gringoKeyword start="#script[ ]*([ ]*python[ ]*)" keepend end="#end" contains=@Python

syn match  gringoKeyword    "#show\W\@="
syn match  gringoKeyword    "#const\W\@="
syn match  gringoKeyword    "#include\W\@="
syn match  gringoKeyword    "#sup\W\@="
syn match  gringoKeyword    "#inf\W\@="
syn match  gringoKeyword    "#supremum\W\@="
syn match  gringoKeyword    "#infimum\W\@="
syn match  gringoKeyword    "#theory\W\@="
syn match  gringoKeyword    "#defined\W\@="
syn match  gringoKeyword    "#minimize\W\@="
syn match  gringoKeyword    "#maximize\W\@="
syn match  gringoKeyword    "#external\W\@="
syn match  gringoKeyword    "#program\W\@="
" legacy keywords
syn match  gringoKeyword    "#ishift\W\@="
syn match  gringoKeyword    "#base\W\@="
syn match  gringoKeyword    "#domain\W\@="
syn match  gringoKeyword    "#hide\W\@="
syn match  gringoKeyword    "#cumulative\W\@="
syn match  gringoKeyword    "#volatile\W\@="
syn match  gringoKeyword    "#incremental\W\@="
syn match  gringoKeyword    "#undef\W\@="
syn match  gringoKeyword    "#disjoint\W\@="
syn match  gringoKeyword    "#minimise\W\@="
syn match  gringoKeyword    "#maximise\W\@="
syn match  gringoKeyword    "#compute\W\@="

syn match  gringoFunction   "#min\W\@="
syn match  gringoFunction   "#max\W\@="
syn match  gringoFunction   "#count\W\@="
syn match  gringoFunction   "#sum\W\@="
syn match  gringoFunction   "\([a-zA-Z0-9_'")]\_s*\)\@<!& *_*[a-z]['a-zA-Z0-9_]*"
" legacy functions
syn match  gringoFunction   "#times\W\@="
syn match  gringoFunction   "#abs\W\@="
syn match  gringoFunction   "#avg\W\@="
syn match  gringoFunction   "#mod\W\@="
syn match  gringoFunction   "#odd\W\@="
syn match  gringoFunction   "#even\W\@="
syn match  gringoFunction   "#pow\W\@="

syn region gringoString     start=+"+ skip=+\\"+ end=+"+
syn match  gringoKey        "\<not\>"
syn match  gringoKey        "#true\W\@="
syn match  gringoKey        "#false\W\@="
syn match  gringoVar        "\<_*[A-Z]['a-zA-Z0-9_]*\>'*"
syn match  gringoOperator   "=\|<\|<=\|>\|>=\|=\|==\|!="
syn match  gringoNumber     "\<[0123456789]*\>"
syn match  gringoRule       ":-"

syn sync maxlines=500

command! -nargs=+ HiLink hi def link <args>

HiLink gringoComment        Comment
HiLink gringoBlockComment   Comment

HiLink gringoKeyword        Type
HiLink gringoFunction       PreProc
HiLink gringoTheory         PreProc
HiLink gringoNumber         Number
HiLink gringoString         String
HiLink gringoOperator       Special
HiLink gringoRule           Special
HiLink gringoVar            Identifier
HiLink gringoError          Error
HiLink gringoKey            Keyword

delcommand HiLink

let b:current_syntax = "gringo"
