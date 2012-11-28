syntax on
set viminfo='1000,f1,<500
set showmatch
set nocompatible
set ignorecase smartcase
set nocompatible
set autoindent
set lisp
set smartindent
set vb t_vb=
set ruler
set incsearch
set virtualedit=all
set background=dark
set complete=.,w,b,u,t,i,]
set showcmd
set nohls

" make that backspace key work the way it should
set backspace=indent,eol,start

nmap <F10> ?(<CR>
nmap <F11> /(<CR>

command! Sh read !cat ~/n/bash_args /!

function! InsertTabWrapper(direction)
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	elseif "backward" == a:direction
		return "\<c-p>"
	else
		return "\<c-n>"
	endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

command! Cleantail :%s#\s*\r\?$##

"search for visually highlighted text
vmap // y/<C-R>"<CR>

filetype on
set omnifunc=syntaxcomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" load the dictionary according to syntax
:au BufReadPost * if exists("b:current_syntax")
:au BufReadPost *   let &dictionary = substitute("~/.vim/dict/FT.dict", "FT", b:current_syntax, "")
:au BufReadPost * endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAC specific
set clipboard=unnamed
set go+=a
set spellfile=~/.vim/spellfile.add

" tell complete to look in the dictionary
set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words
set complete-=k complete+=k

if has("gui")
  colorscheme darkblue
  set guifont=Monaco:h14
else
  " colorscheme default
  colorscheme darkblue
endif

" show whitespace at end of lines
highlight WhitespaceEOL term=underline ctermbg=lightgrey guibg=lightgray
match WhitespaceEOL /\s\+$/

set shiftwidth=1
set foldmethod=indent
set foldlevel=100


" VIM AS PAGER OPTIONS

" Status line
set laststatus=0
set cmdheight=1
set nomodifiable	" Only in version 6.0
set readonly

" Key bindings.
nmap b <C-B><C-G>
nmap q :q<CR>
nmap <space> <C-F><C-G>
