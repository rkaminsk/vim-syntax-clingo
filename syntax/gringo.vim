" Vim syntax file
" Language:    Gringo
" Maintainer:  Roland Kaminski
" Last Change: 2020 Jun 29

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

syn iskeyword @,48-57,192-255,#
syn case match

syn match   gringoKeyword  "\*%"
syn match   gringoComment  +%.*+
syn region  gringoBlockComment start="%\*" end="\*%" fold

syn match   gringoError    "#.*"

syn region  luaCode        matchgroup=gringoKeyword start="#begin_lua" keepend end="#end_lua" contains=@Lua fold
syn region  luaCode        matchgroup=gringoKeyword start="#script[ ]*([ ]*lua[ ]*)" keepend end="#end" contains=@Lua fold
syn region  pythonCode     matchgroup=gringoKeyword start="#script[ ]*([ ]*python[ ]*)" keepend end="#end" contains=@Python fold

syn keyword gringoKeyword  #show
syn keyword gringoKeyword  #const
syn keyword gringoKeyword  #include
syn keyword gringoKeyword  #sup
syn keyword gringoKeyword  #inf
syn keyword gringoKeyword  #supremum
syn keyword gringoKeyword  #infimum
syn keyword gringoKeyword  #theory
syn keyword gringoKeyword  #defined
syn keyword gringoKeyword  #minimize
syn keyword gringoKeyword  #maximize
syn keyword gringoKeyword  #external
syn keyword gringoKeyword  #program
" legacy keywords
syn keyword gringoKeyword  #ishift
syn keyword gringoKeyword  #base
syn keyword gringoKeyword  #domain
syn keyword gringoKeyword  #hide
syn keyword gringoKeyword  #cumulative
syn keyword gringoKeyword  #volatile
syn keyword gringoKeyword  #incremental
syn keyword gringoKeyword  #undef
syn keyword gringoKeyword  #disjoint
syn keyword gringoKeyword  #minimise
syn keyword gringoKeyword  #maximise
syn keyword gringoKeyword  #compute

syn keyword gringoFunction #min
syn keyword gringoFunction #max
syn keyword gringoFunction #count
syn keyword gringoFunction #sum
syn match   gringoFunction "\([a-zA-Z0-9_'")]\_s*\)\@<!& *_*[a-z]['a-zA-Z0-9_]*"
" legacy functions
syn keyword gringoFunction #times
syn keyword gringoFunction #abs
syn keyword gringoFunction #avg
syn keyword gringoFunction #mod
syn keyword gringoFunction #odd
syn keyword gringoFunction #even
syn keyword gringoFunction #pow

syn region  gringoString   start=+"+ skip=+\\"+ end=+"+
syn keyword gringoKey      not
syn keyword gringoKey      #true
syn keyword gringoKey      #false
syn match   gringoVar      "\<_*[A-Z]['a-zA-Z0-9_]*\>'*"
syn match   gringoOperator "=\|<\|<=\|>\|>=\|=\|==\|!="
syn match   gringoNumber   "\<[0123456789]*\>"
syn match   gringoRule     ":-"
syn match   gringoRule     ":\~"

syn sync maxlines=500

command! -nargs=+ HiLink hi def link <args>

HiLink gringoComment      Comment
HiLink gringoBlockComment Comment

HiLink gringoKeyword      Type
HiLink gringoFunction     PreProc
HiLink gringoTheory       PreProc
HiLink gringoNumber       Number
HiLink gringoString       String
HiLink gringoOperator     Special
HiLink gringoRule         Special
HiLink gringoVar          Identifier
HiLink gringoError        Error
HiLink gringoKey          Keyword

delcommand HiLink

let b:current_syntax = "gringo"
