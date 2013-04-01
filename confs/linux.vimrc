" {{{ vim variables
set tabstop=4
set shiftwidth=4
set expandtab
set nocompatible
set cursorline
set autoread
set viminfo='1000,f1,<500
set showmatch
set ignorecase smartcase
set autoindent
set smartindent
set shiftround
set lisp
set vb t_vb=
set ruler
set incsearch
set virtualedit=all
set background=dark
set complete=.,w,b,u,i,]
set showcmd
set nohls
set backspace=indent,eol,start
set autochdir
set hidden
set hlsearch
set wildchar=<Tab> wildmenu wildmode=full
set wildcharm=<C-Z>
let Tlist_WinWidth = 50
nnoremap <silent> <F8> :TlistToggle<CR>
nnoremap <F9> :b <C-Z>
" }}}

"{{{ Appearance
colorscheme desert
syntax on

if &t_Co == 8 && $TERM !~# '^linux'
  set t_Co=16
endif

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if has("gui_running")
    set transparency=30
    set guioptions=egmLtA
    set guifont=Menlo\ Regular:h14
    set fuoptions=maxvert,maxhorz
    au GUIEnter * set fullscreen

    " gvim tab switching
    :macm Window.Select\ Previous\ Tab  key=<D-Left>
    :macm Window.Select\ Next\ Tab  key=<D-Right>
    noremap <D-1> :tabn 1<CR>
    noremap <D-2> :tabn 2<CR>
    noremap <D-3> :tabn 3<CR>
    noremap <D-4> :tabn 4<CR>
    noremap <D-5> :tabn 5<CR>
    noremap <D-6> :tabn 6<CR>
    noremap <D-7> :tabn 7<CR>
    noremap <D-8> :tabn 8<CR>
    noremap <D-9> :tabn 9<CR>
    noremap <D-0> :tablast<CR>
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
  if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u00b7"
  endif
endif
set list

" {{{ OLD: show whitespace at end of lines
" highlight ExtraWhitespace ctermbg=White guibg=White
" autocmd ColorScheme * highlight ExtraWhitespace ctermbg=White guibg=White
" match ExtraWhitespace /\s\+$/
" autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" autocmd BufWinLeave * call clearmatches()
" hi CursorLine  cterm=NONE guibg=#003399
" }}}

" {{{ status line
set statusline=%F         "tail of the filename
set statusline+=%=        "left/right separator
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}]\  "file format
set statusline+=%h\       "help file flag
set statusline+=%m\       "modified flag
set statusline+=%r\       "read only flag
set statusline+=%y\       "filetype
set statusline+=%c,\      "cursor column
set statusline+=%l/%L     "cursor line/total lines
set statusline+=\ %P      "percent through file
set laststatus=2
" }}}
"}}}

" Key Bindings & Mappings
vmap // y/<C-R>"<CR>
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
map gr :grep <cword> *<CR>
map gr :grep <cword> %:p:h/*<CR>
map gR :grep \b<cword>\b *<CR>
map GR :grep \b<cword>\b %:p:h/*<CR>
map yc "*yy
map yr yab :echo system('nc localhost 37146', @")<CR>
map yv yw :echo system('nc localhost 37146', @")<CR>
map pr :echo system('nc localhost 37146', @")<CR>

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

" open the file under the cursor
" map gf :!open <C-R><C-P><CR>

nmap <F10> ?(<CR>
nmap <F11> /(<CR>

" custom commands
command! GREP :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
" map * :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
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

" include the .org mode conf
" so ~/.vim/extra_conf/vim.org.rc

execute pathogen#infect()

" Folding
set foldmethod=marker
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf
" vim custom fold display function
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
set foldtext=CustomFoldText()
