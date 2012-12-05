"{{{  general preferences for vim
" colorscheme ir_black
set foldmethod=marker
set tabstop=4
set shiftwidth=4
" set expandtab
set nocompatible
set cursorline
set autoread
set viminfo='1000,f1,<500
set showmatch
set ignorecase smartcase
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
"}}}

"{{{ Appearance
colorscheme desert
syntax on

if has("gui_running")
    " gvim tab switching
    :macm Window.Select\ Previous\ Tab  key=<D-Left>
    :macm Window.Select\ Next\ Tab  key=<D-Right>
	set transparency=30
	set guioptions=egmLt
	" set guifont=Bitstream\ Vera\ Sans\ Mono:h16
    " set guifont=Courier\ New:h16
	set guifont=Menlo\ Regular:h18
	" set columns=164
	" set lines=41
	set fuoptions=maxvert,maxhorz
	au GUIEnter * set fullscreen
 endif
" show whitespace at end of lines
highlight WhitespaceEOL ctermbg=lightgray guibg=lightgray
match WhiteSpaceEOL /\s\+$/
hi CursorLine  cterm=NONE guibg=#003399
"}}}

"{{{ mappings
"search for visually highlighted text
vmap // y/<C-R>"<CR>
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
map gr :grep <cword> *<CR>
map gr :grep <cword> %:p:h/*<CR>
map gR :grep \b<cword>\b *<CR>
map GR :grep \b<cword>\b %:p:h/*<CR>
" nmap <F10> ?(<CR>
" nmap <F11> /(<CR>
"}}}

" custom commands
" command GREP :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
command! Cleantail :%s#\s*\r\?$##

"{{{ Autocompletion 
" filetype on
set omnifunc=syntaxcomplete#Complete
set completeopt=longest,menuone
" autocmd FileType python set omnifunc=pythoncomplete#Complete
" autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
" autocmd FileType css set omnifunc=csscomplete#CompleteCSS
" autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
" autocmd FileType php set omnifunc=phpcomplete#CompletePHP
" autocmd FileType c set omnifunc=ccomplete#Complete

" load the dictionary according to syntax
" :au BufReadPost * if exists("b:current_syntax")
" :au BufReadPost * let &dictionary = substitute("~/.vim/dict/FT.dict", "FT", b:current_syntax, "")
" :au BufReadPost * endif
"}}}

"{{{ functions
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
"}}}

" include the .org mode conf
so ~/.vim/extra_conf/vim.org.rc
