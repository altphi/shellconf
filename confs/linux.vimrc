" general preferences for vim
" colorscheme ir_black
colorscheme desert
syntax on
set tabstop=4
set shiftwidth=4
" set expandtab
set nocompatible
set cursorline
set autoread
set viminfo='1000,f1,<500
set showmatch
set ignorecase smartcase
" set autoindent
set lisp
" set smartindent
set vb t_vb=
set ruler
set incsearch
set virtualedit=all
set background=dark
set complete=.,w,b,u,i,]
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
	set guioptions=egmLtA
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


" mappings
"search for visually highlighted text
vmap // y/<C-R>"<CR>
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
map gr :grep <cword> *<CR>
map gr :grep <cword> %:p:h/*<CR>
map gR :grep \b<cword>\b *<CR>
map GR :grep \b<cword>\b %:p:h/*<CR>
" toss the yank register to Guile repl on default port 37146
"map yr :let replresult = system('nc localhost 37146', @")<CR> :let replresult 
"map yr :call system('nc localhost 37146', @")<CR>
map yr :!echo '<C-R>"' <Bar> nc localhost 37146 <CR>


" open the file under the cursor
" map gf :!open <C-R><C-P><CR>

nmap <F10> ?(<CR>
nmap <F11> /(<CR>


" custom commands
command GREP :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
map * :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>

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
let g:vimwiki_table_mappings = 0
let g:vimwiki_camel_case = 1
let g:vimwiki_auto_checkbox = 1
let g:vimwiki_use_mouse=1
let g:vimwiki_folding=0 " 0 = off
nmap <leader>tt <Plug>VimwikiToggleListItem
let g:vimwiki_list = [{'path': '~/Documents/vimwiki/', 'syntax': 'default'}] 
" change these two in default file because override does not seem to work (~/.vim/syntax/vimwiki_default.vim)
let g:vimwiki_rxPreStart = '{{{{'
let g:vimwiki_rxPreEnd = '}}}}'
" also, for HTML output, change the below in autoload/vimwiki/html.vim (and
" the lines between these two as well
" if !pre[0] && a:line =~ '^\s*{{{'   AND
" elseif pre[0] && a:line =~ '^\s*}}}\s*$'
"
" nnoremap <Leader>[ lbi[[<Esc>ea]]<Esc>
" vnoremap <Leader>[ lbi[[<Esc>ea]]<Esc>
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

" hi Cursor ctermbg=white guibg=white
" hi MatchParen ctermbg=blue

" include the .org mode conf
so ~/.vim/extra_conf/vim.org.rc

" {{{ Folding
set foldmethod=marker
" set foldcolumn=1
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf
" }}}

" {{{ vim custom fold display function
"
function! CustomFoldText()
" slightly altered function via
" http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
"get first non-blank line
 let fs = v:foldstart
 while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
 endwhile
if fs > v:foldend
     let line = getline(v:foldstart)
  else
       let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif

	let line = substitute(line, "{{{", '', 'g')

    let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = repeat("+--", v:foldlevel)
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
    return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endf
" }}}
set foldtext=CustomFoldText()
