" general preferences for vim
" colorscheme ir_black
colorscheme desert
syntax on
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

"{{{ Appearance
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
	" au GUIEnter * set fullscreen
 endif

" show whitespace at end of lines
highlight WhitespaceEOL ctermbg=lightgray guibg=lightgray
match WhiteSpaceEOL /\s\+$/
hi CursorLine  cterm=NONE guibg=#003399
"}}}


" mappings
"search for visually highlighted text
vmap // y/<C-R>"<CR>
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
map gr :grep <cword> *<CR>
map gr :grep <cword> %:p:h/*<CR>
map gR :grep \b<cword>\b *<CR>
map GR :grep \b<cword>\b %:p:h/*<CR>


" open the file under the cursor
map gf :!open <C-R><C-P><CR>


nmap <F10> ?(<CR>
nmap <F11> /(<CR>


" custom commands
" command GREP :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
command! Sh read !cat ~/n/bash_args /!
command! Cleantail :%s#\s*\r\?$##
command! WC :w !wc



"{{{ Autocompletion 
filetype on
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


"{{{  vimWiki
set nocompatible
filetype plugin on
syntax on
let g:vimwiki_camel_case = 1
let g:vimwiki_auto_checkbox = 1
let g:vimwiki_use_mouse=1
let g:vimwiki_folding=0 " 0 = off
nmap <leader>tt <Plug>VimwikiToggleListItem
" let g:Tlist_Use_Right_Window=1
" let g:Tlist_WinWidth=25
" If ctags not in $path, set this.
" let Tlist_Ctags_Cmd='path\to\ctags.exe'
" nnoremap <F12> :TlistToggle<CR>
" let tlist_vimwiki_settings = 'wiki;h:Headers'
let g:vimwiki_list = [{'path': '~/Documents/vimwiki/', 'syntax': 'default'}] 
" change these two in default file because override does not seem to work (~/.vim/syntax/vimwiki_default.vim)
let g:vimwiki_rxPreStart = '{{{{'
let g:vimwiki_rxPreEnd = '}}}}'
" nnoremap <Leader>[ lbi[[<Esc>ea]]<Esc>
" vnoremap <Leader>[ lbi[[<Esc>ea]]<Esc>
"}}}


" au BufRead,BufNewFile *.txt set filetype=text
" autocmd FileType text syn match TextTag "\*[a-zA-Z]*\*"
" autocmd FileType text syn match TextJump "|[a-zA-Z]*|"
" hi def link TextTag String
" hi def link TextJump Comment
" au BufNewFile,BufRead /Users/stephen/Documents/notes/* set filetype=help



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


let g:netrw_rsync_cmd = "rsync -e 'ssh -i /Users/stephen/.ssh/qc' -a"


hi Cursor ctermbg=white guibg=white
hi MatchParen ctermbg=blue
