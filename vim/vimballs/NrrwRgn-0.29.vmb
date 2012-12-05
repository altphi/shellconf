" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/NrrwRgn.vim	[[[1
68
" NrrwRgn.vim - Narrow Region plugin for Vim
" -------------------------------------------------------------
" Version:	   0.29
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Mon, 20 Aug 2012 19:34:23 +0200
"
" Script: http://www.vim.org/scripts/script.php?script_id=3075
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim
"			   (see |copyright|) except use "NrrwRgn.vim"
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3075 29 :AutoInstall: NrrwRgn.vim
"
" Init: {{{1
let s:cpo= &cpo
if exists("g:loaded_nrrw_rgn") || &cp
  finish
endif
set cpo&vim
let g:loaded_nrrw_rgn = 1

" Debug Setting
let s:debug=0
if s:debug
	exe "call nrrwrgn#Debug(1)"
endif

" ----------------------------------------------------------------------------
" Public Interface: {{{1

" Define the Command aliases "{{{2
com! -range -bang NRPrepare :<line1>,<line2>NRP<bang>
com! -range NarrowRegion :<line1>,<line2>NR
com! -bang NRMulti :NRM<bang>
com! -bang NarrowWindow :NW
com! -bang NRLast :NRL

" Define the actual Commands "{{{2
com! -range -bang NR	 :<line1>, <line2>call nrrwrgn#NrrwRgn(<q-bang>)
com! -range NRP  :exe ":" . <line1> . ',' . <line2> . 'call nrrwrgn#Prepare()'
com! NRV :call nrrwrgn#VisualNrrwRgn(visualmode())
com! NUD :call nrrwrgn#UnifiedDiff()
com! -bang NW	 :exe ":" . line('w0') . ',' . line('w$') . "call nrrwrgn#NrrwRgn(<q-bang>)"
com! -bang NRM :call nrrwrgn#NrrwRgnDoPrepare(<q-bang>)
com! -bang NRL :call nrrwrgn#LastNrrwRgn(<q-bang>)

" Define the Mapping: "{{{2
if !hasmapto('<Plug>NrrwrgnDo')
	xmap <unique> <Leader>nr <Plug>NrrwrgnDo
endif
if !hasmapto('<Plug>NrrwrgnBangDo')
	xmap <unique> <Leader>Nr <Plug>NrrwrgnBangDo
endif
if !hasmapto('VisualNrrwRgn')
	xnoremap <unique> <script> <Plug>NrrwrgnDo <sid>VisualNrrwRgn
endif
if !hasmapto('VisualNrrwRgnBang')
	xnoremap <unique> <script> <Plug>NrrwrgnBangDo <sid>VisualNrrwBang
endif
xnoremap <sid>VisualNrrwRgn :<c-u>call nrrwrgn#VisualNrrwRgn(visualmode(),'')<cr>
xnoremap <sid>VisualNrrwBang :<c-u>call nrrwrgn#VisualNrrwRgn(visualmode(),'!')<cr>

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\"
autoload/nrrwrgn.vim	[[[1
1170
" nrrwrgn.vim - Narrow Region plugin for Vim
" -------------------------------------------------------------
" Version:	   0.29
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Mon, 20 Aug 2012 19:34:23 +0200
"
" Script: http://www.vim.org/scripts/script.php?script_id=3075 
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"			   The VIM LICENSE applies to NrrwRgn.vim 
"			   (see |copyright|) except use "NrrwRgn.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3075 29 :AutoInstall: NrrwRgn.vim
"
" Functions:

fun! <sid>WarningMsg(msg) "{{{1
	let msg = "NarrowRegion: " . a:msg
	echohl WarningMsg
	if exists(":unsilent") == 2
		unsilent echomsg msg
	else
		echomsg msg
	endif
	sleep 1
	echohl Normal
	let v:errmsg = msg
endfun

fun! <sid>Init() "{{{1
	if !exists("s:opts")
		" init once
		let s:opts = []
	endif
	if !exists("s:instn")
		let s:instn=1
		if !exists("g:nrrw_custom_options") || empty(g:nrrw_custom_options)
			let s:opts=<sid>Options('local to buffer')
        endif
	else
		" Prevent accidently overwriting windows with instn_id set
		" back to an already existing instn_id
		let s:instn = (s:instn==0 ? 1 : s:instn)
		while (has_key(s:nrrw_rgn_lines, s:instn))
			let s:instn+=1
		endw
	endif
	let s:nrrw_aucmd = {}
	if exists("b:nrrw_aucmd_create")
		let s:nrrw_aucmd["create"] = b:nrrw_aucmd_create
	endif
	if exists("b:nrrw_aucmd_close")
		let s:nrrw_aucmd["close"] = b:nrrw_aucmd_close
	endif
	if !exists("s:nrrw_rgn_lines")
		let s:nrrw_rgn_lines = {}
	endif
	let s:nrrw_rgn_lines[s:instn] = {}
	" show some debugging messages
	let s:nrrw_winname='Narrow_Region'

	" Customization
	let s:nrrw_rgn_vert = (exists("g:nrrw_rgn_vert") ? g:nrrw_rgn_vert : 0)
	let s:nrrw_rgn_wdth = (exists("g:nrrw_rgn_wdth") ? g:nrrw_rgn_wdth : 20)
	let s:nrrw_rgn_hl	= (exists("g:nrrw_rgn_hl")	 ? g:nrrw_rgn_hl   :
							\ "WildMenu")
	let s:nrrw_rgn_nohl = (exists("g:nrrw_rgn_nohl") ? g:nrrw_rgn_nohl : 0)

	let s:debug         = (exists("s:debug") ? s:debug : 0)
		
endfun 

fun! <sid>NrwRgnWin() "{{{1
	let local_options = <sid>GetOptions(s:opts)
	let nrrw_winname = s:nrrw_winname . '_' . s:instn
	let nrrw_win = bufwinnr('^'.nrrw_winname.'$')
	if nrrw_win != -1
		exe ":noa " . nrrw_win . 'wincmd w'
		" just in case, a global nomodifiable was set 
		" disable this for the narrowed window
		setl ma
		silent %d _
		noa wincmd p
	else
		if !exists('g:nrrw_topbot_leftright')
			let g:nrrw_topbot_leftright = 'topleft'
		endif
		exe  g:nrrw_topbot_leftright s:nrrw_rgn_wdth .
			\(s:nrrw_rgn_vert?'v':'') . "sp " . nrrw_winname
		" just in case, a global nomodifiable was set 
		" disable this for the narrowed window
		setl ma
		" Just in case
		silent %d _
		" Set up some options like 'bufhidden', 'noswapfile', 
		" 'buftype', 'bufhidden', when enabling Narrowing.
		call <sid>NrrwSettings(1)
		let nrrw_win = bufwinnr("")
	endif
	call <sid>SetOptions(local_options)
	return nrrw_win
endfun

fun! <sid>CleanRegions() "{{{1
	 let s:nrrw_rgn_line=[]
	 unlet! s:nrrw_rgn_last
	 unlet! s:nrrw_rgn_buf
endfun

fun! <sid>CompareNumbers(a1,a2) "{{{1
	return (a:a1+0) == (a:a2+0) ? 0
		\ : (a:a1+0) > (a:a2+0) ? 1
		\ : -1
endfun

fun! <sid>ParseList(list) "{{{1
	 " for a given list of line numbers, return those line numbers
	 " in a format start:end for continous items, else [start, next]
     let result={}
     let start=0
     let temp=0
     let i=1
     for item in sort(a:list, "<sid>CompareNumbers")
         if start==0
            let start=item
		 elseif temp!=item-1
             let result[i]=[start,temp]
             let start=item
			 let i+=1
         endif
		 let temp=item
     endfor
	 if result[i-1][1] != item
		 let result[i]=[start,item]
	 endif
     return result
endfun

fun! <sid>WriteNrrwRgn(...) "{{{1
	" if argument is given, write narrowed buffer back
	" else destroy the narrowed window
	let nrrw_instn = exists("b:nrrw_instn") ? b:nrrw_instn : s:instn
	if exists("b:orig_buf") && (bufwinnr(b:orig_buf) == -1) &&
		\ !<sid>BufInTab(b:orig_buf) &&
		\ !bufexists(b:orig_buf)
		call s:WarningMsg("Original buffer does no longer exist! Aborting!")
		return
	endif
	if &l:mod && exists("a:1") && a:1
		" Write the buffer back to the original buffer
		setl nomod
		exe ":WidenRegion"
		if bufname('') !~# 'Narrow_Region'
			exe ':noa' . bufwinnr(s:nrrw_winname . '_' . s:instn) . 'wincmd w'
		endif
	else
		call <sid>StoreLastNrrwRgn(nrrw_instn)
		let winnr = bufwinnr(b:orig_buf)
		" Best guess
		if bufname('') =~# 'Narrow_Region' && winnr > 0
			exe ':noa' . winnr . 'wincmd w'
		endif
		if !exists("a:1") 
			" close narrowed buffer
			call <sid>NrrwRgnAuCmd(nrrw_instn)
		endif
	endif
endfun

fun! <sid>SaveRestoreRegister(mode) "{{{1
	if a:mode
		let s:savereg  = getreg('a')
		let s:saveregt = getregtype('a')
		let s:fold = 0
		if &fen
			let s:fold=1
			setl nofoldenable
			let s:fdm = &l:fdm
		endif
	else
		call setreg('a', s:savereg, s:saveregt)
		if s:fold
			setl foldenable
			if exists("s:fdm")
				let &l:fdm=s:fdm
			endif
		endif
	endif
endfun!

fun! <sid>NrrwRgnAuCmd(instn) "{{{1
	" If a:instn==0, then enable auto commands
	" else disable auto commands for a:instn
	if !a:instn
		exe "aug NrrwRgn" . b:nrrw_instn
			au!
			au BufWriteCmd <buffer> nested :call s:WriteNrrwRgn(1)
			au BufWinLeave,BufWipeout,BufDelete <buffer> nested
						\ :call s:WriteNrrwRgn()
		aug end
	else
		exe "aug NrrwRgn" .  a:instn
		au!
		aug end
		exe "aug! NrrwRgn" . a:instn
		
		if !has_key(s:nrrw_rgn_lines, a:instn)
			" narrowed buffer was already cleaned up
			call s:WarningMsg("Window was already cleaned up. Nothing to do.")
			return
		endif

		" make the original buffer modifiable, if possible
		let buf = s:nrrw_rgn_lines[a:instn].orig_buf
		if !getbufvar(buf, '&l:ma') && !getbufvar(buf, 'orig_buf_ro')
			call setbufvar(s:nrrw_rgn_lines[a:instn].orig_buf, '&ma', 1)
		endif

		if s:debug
			echo printf("bufnr: %d a:instn: %d\n", bufnr(''), a:instn)
			echo "bwipe " s:nrrw_winname . '_' . a:instn
		endif
		if (has_key(s:nrrw_rgn_lines[a:instn], 'disable') &&
		\	!s:nrrw_rgn_lines[a:instn].disable ) ||
		\   !has_key(s:nrrw_rgn_lines[a:instn], 'disable')
			call <sid>DeleteMatches(a:instn)
			" bwipe! throws E855 (catching does not work)
			" but because of 'bufhidden' wipeing will happen anyways
			"exe "bwipe! " bufnr(s:nrrw_winname . '_' . a:instn)
			if has_key(s:nrrw_rgn_lines[a:instn], 'single') &&
			\  s:nrrw_rgn_lines[a:instn].single
				" If there is only a single window open don't clean up now
				" because we can't put the narrowed lines back, so do not
				" clean up now. We need to clean up then later. But how?
				return
			endif
			call <sid>CleanUpInstn(a:instn)
		endif
	endif
endfun

fun! <sid>CleanUpInstn(instn) "{{{1
	if s:instn>=1 && has_key(s:nrrw_rgn_lines, 'a:instn')
		unlet s:nrrw_rgn_lines[a:instn]
		let s:instn-=1
	endif
endfu

fun! <sid>StoreLastNrrwRgn(instn) "{{{1
	" Only store the last region, when the narrowed instance is still valid
	if !has_key(s:nrrw_rgn_lines, a:instn)
		call <sid>WarningMsg("Error storing the last Narrowed Window,".
					\ "it's invalid!")
		return
	endif

	let s:nrrw_rgn_lines['last'] = []
	if !exists("b:orig_buf")
		let orig_buf = s:nrrw_rgn_lines[a:instn].orig_buf
	else
		let orig_buf = b:orig_buf
	endif
	if has_key(s:nrrw_rgn_lines[a:instn], 'multi')
		call add(s:nrrw_rgn_lines['last'], [ orig_buf, 
			\ s:nrrw_rgn_lines[a:instn]['multi']])
	elseif has_key(s:nrrw_rgn_lines[a:instn], 'vmode')
		let s:nrrw_rgn_lines['last'] = [ getpos("'<"),
		\ getpos("'>") ]
		call add(s:nrrw_rgn_lines['last'], s:nrrw_rgn_lines[a:instn].vmode)
	else
		" Linewise narrowed region, pretend it was done like a visual
		" narrowed region
		let s:nrrw_rgn_lines['last'] = [ [ orig_buf,
		\ s:nrrw_rgn_lines[a:instn].start[1:]], 
		\ [ orig_buf, s:nrrw_rgn_lines[a:instn].end[1:]]]
		call add(s:nrrw_rgn_lines['last'], 'V')
	endif
endfu

fun! <sid>RetVisRegionPos() "{{{1
	if v:version > 703 || (v:version == 703 && has("patch590"))
		return [ getpos("'<"), getpos("'>") ]
	else
		return [ getpos("'<")[0:1] + [virtcol("'<"), 0],
			\    getpos("'>")[0:1] + [virtcol("'>"), 0] ]
	endif
endfun

fun! <sid>GeneratePattern(startl, endl, mode, ...) "{{{1
	if exists("a:1") && a:1
		let block = 0
	else
		let block = 1
	endif
	" This is just a best guess, the highlighted block could still be wrong
	" (a " rectangle has been selected, but the complete lines are
	" highlighted
	if a:mode ==# '' && a:startl[0] > 0 && a:startl[1] > 0 && block
		return '\%>' . (a:startl[0]-1) . 'l\&\%>' . (a:startl[1]-1) .
			\ 'v\&\%<' . (a:endl[0]+1) . 'l'
	elseif a:mode ==# '' && a:startl[0] > 0 && a:startl[1] > 0
		return '\%>' . (a:startl[0]-1) . 'l\&\%>' . (a:startl[1]-1) .
			\ 'v\&\%<' . (a:endl[0]+1) . 'l\&\%<' . (a:endl[1]+1) . 'v'
	elseif a:mode ==# 'v' && a:startl[0] > 0 && a:startl[1] > 0
		return '\%>' . (a:startl[0]-1) . 'l\&\%>' . (a:startl[1]-1) .
			\ 'v\_.*\%<' . (a:endl[0]+1) . 'l\&\%<' . (a:endl[1]+1) . 'v'
	elseif a:startl[0] > 0
		return '\%>' . (a:startl[0]-1) . 'l\&\%<' . (a:endl[0]+1) . 'l'
	else
		return ''
	endif
endfun 

fun! <sid>Options(search) "{{{1
	let c=[]
	let buf=bufnr('')
	try
		" empty search pattern
		if empty(a:search)
			return c
		endif
		silent noa sview $VIMRUNTIME/doc/options.txt
		" for whatever reasons $VIMRUNTIME/doc/options.txt
		" does not exist, return empty list
		if line('$') == 1
			return c
		endif
		keepj 0
		let reg_a=[]
		call add(reg_a, 'a')
		call add(reg_a,getreg('a'))
		call add(reg_a, getregtype('a'))
		let @a=''
		exe "silent :g/" . '\v'.escape(a:search, '\\/') . "/-y A"
		let b=split(@a, "\n")
		call call('setreg', reg_a)
		"call setreg('a', reg_a[0], reg_a[1])
		call filter(b, 'v:val =~ "^''"')
		" the following options should be set
		let filter_opt='\%(modifi\%(ed\|able\)\|readonly\|noswapfile\|' .
				\ 'buftype\|bufhidden\|foldcolumn\|buflisted\)'
		call filter(b, 'v:val !~ "^''".filter_opt."''"')
		for item in b
			let item=substitute(item, '''', '', 'g')
			call add(c, split(item, '\s\+')[0])
		endfor
	finally
		if fnamemodify(bufname(''),':p') ==
		   \expand("$VIMRUNTIME/doc/options.txt")
			bwipe
		endif
		exe "noa "	bufwinnr(buf) "wincmd  w"
		return c
	endtry
endfun

fun! <sid>GetOptions(opt) "{{{1
	if exists("g:nrrw_custom_options") && !empty(g:nrrw_custom_options)
		let result = g:nrrw_custom_options
	else
		let result={}
		for item in a:opt
			try
				exe "let result[item]=&l:".item
			catch
			endtry
		endfor
	endif
	return result
endfun

fun! <sid>SetOptions(opt) "{{{1
	 if type(a:opt) == type({})
		for [option, result] in items(a:opt)
			exe "let &l:". option " = " string(result)
		endfor
	 endif
	 setl nomod noro
endfun

fun! <sid>CheckProtected() "{{{1
	" Protect the original window, unless the user explicitly defines not to
	" protect it
	if exists("g:nrrw_rgn_protect") && g:nrrw_rgn_protect =~? 'n'
		return
	endif
	let b:orig_buf_ro=0
	if !&l:ma || &l:ro
		let b:orig_buf_ro=1
		call s:WarningMsg("Buffer is protected, won't be able to write".
			\ "the changes back!")
	else 
	" Protect the original buffer,
	" so you won't accidentally modify those lines,
	" that might later be overwritten
		setl noma
	endif
endfun

fun! <sid>DeleteMatches(instn) "{{{1
    " Make sure, we are in the correct buffer
	if bufname('') =~# 'Narrow_Region'
		exe ':noa' . bufwinnr(b:orig_buf) . 'wincmd w'
	endif
	if exists("s:nrrw_rgn_lines[a:instn].matchid")
		" if you call :NarrowRegion several times, without widening 
		" the previous region, b:matchid might already be defined so
		" make sure, the previous highlighting is removed.
		for item in s:nrrw_rgn_lines[a:instn].matchid
			if item > 0
				" If the match has been deleted, discard the error
				exe (s:debug ? "" : "silent!") "call matchdelete(item)"
			endif
		endfor
		let s:nrrw_rgn_lines[a:instn].matchid=[]
	endif
endfun

fun! <sid>HideNrrwRgnLines() "{{{1
	let cnc = has("Conceal")
	let cmd='syn match NrrwRgnStart "^# Start NrrwRgn\d\+$" '.
				\ (cnc ? 'conceal' : '')
	exe cmd
	let cmd='syn match NrrwRgnEnd "^# End NrrwRgn\d\+$" '.
				\ (cnc ? 'conceal' : '')
	exe cmd
	syn region NrrwRgn start="^# Start NrrwRgn\z(\d\+\).*$"
		\ end="^# End NrrwRgn\z1$" fold transparent
	if cnc
		setl conceallevel=3
	endif
	setl fdm=syntax
endfun

fun! <sid>ReturnCommentFT() "{{{1
	" Vim
	if &l:ft=="vim"
		return '"'
	" Perl, PHP, Ruby, Python, Sh
	elseif &l:ft=~'^\(perl\|php\|ruby\|python\|sh\)$'
	    return '#'
	" C, C++
	elseif &l:ft=~'^\(c\%(pp\)\?\|java\)'
		return '/* */'
	" HTML, XML
	elseif &l:ft=~'^\(ht\|x\)ml\?$'
		return '<!-- -->'
	" LaTex
	elseif &l:ft=~'^\(la\)tex'
		return '%'
	else
		" Fallback
		return '#'
	endif
endfun

fun! <sid>CheckRectangularRegion(reg) "{{{1
	" Check whether the region that was pasted into
	" register a:reg has always the same length
	" This is needed, to be able to select the correct region
	" when writing back the changes.
	let result={}
	let list=split(a:reg, "\n")
	call map(list, 'substitute(v:val, ".", "x", "g")')
	let llen = len(list)/2
	call map(list, 'len(v:val)')
	for item in list
		if has_key(result, item)
			let result[item] += 1
		else
			let result[item] = 1
		endif
	endfor
	for [key, value] in items(result)
		if value > llen
			return 1
		endif
	endfor
	return 0
endfu

fun! <sid>WidenRegionMulti(content, instn, close) "{{{1
	" a:close: if set, the original narrowed buffer will be closed,
	" so don't renew the highlighting and clean up (later in
	" nrrwrgn#WidenRegion)
	if empty(s:nrrw_rgn_lines[a:instn].multi)
		return
	endif

	let output= []
	let list  = []
	let [c_s, c_e] =  <sid>ReturnComments()
	let lastline = line('$')
	" We must put the regions back from top to bottom,
	" otherwise, changing lines in between messes up the list of lines that
	" still need to put back from the narrowed buffer to the original buffer
	for key in sort(keys(s:nrrw_rgn_lines[a:instn].multi),
			\ "<sid>CompareNumbers")
		let adjust   = line('$') - lastline
		let range    = s:nrrw_rgn_lines[a:instn].multi[key]
		let last     = (len(range)==2) ? range[1] : range[0]
		let first    = range[0]
		let indexs   = index(a:content, c_s.' Start NrrwRgn'.key.c_e) + 1
		let indexe   = index(a:content, c_s.' End NrrwRgn'.key.c_e) - 1
		if indexs <= 0 || indexe < -1
		   call s:WarningMsg("Skipping Region " . key)
		   continue
		endif
		" Adjust line numbers. Changing the original buffer, might also 
		" change the regions we have remembered. So we must adjust these
		" numbers.
		" This only works, if we put the regions from top to bottom!
		let first += adjust
		let last  += adjust
		if last == line('$') &&  first == 1
			let delete_last_line=1
		else
			let delete_last_line=0
		endif
		exe ':silent :' . first . ',' . last . 'd _'
		call append((first-1), a:content[indexs : indexe])
		" Recalculate the start and end positions of the narrowed window
		" so subsequent calls will adjust the region accordingly
		let  last = first + len(a:content[indexs : indexe]) - 1
		if last > line('$')
			let last = line('$')
		endif
		if !a:close
			" original narrowed buffer is going to be closed
			" so don't renew the matches
			call <sid>AddMatches(<sid>GeneratePattern([first, 0 ],
						\ [last, 0], 'V'), a:instn)
		endif
		if delete_last_line
			silent! $d _
		endif
	endfor
endfun
	
fun! <sid>AddMatches(pattern, instn) "{{{1
	if !s:nrrw_rgn_nohl || empty(a:pattern)
		if !exists("s:nrrw_rgn_lines[a:instn].matchid")
			let s:nrrw_rgn_lines[a:instn].matchid=[]
		endif
		call add(s:nrrw_rgn_lines[a:instn].matchid,
					\matchadd(s:nrrw_rgn_hl, a:pattern))
	endif
endfun

fun! <sid>BufInTab(bufnr) "{{{1
	for tab in range(1,tabpagenr('$'))
		if !empty(filter(tabpagebuflist(tab), 'v:val == a:bufnr'))
			return tab
		endif
	endfor
	return 0
endfun

fun! <sid>JumpToBufinTab(tab,buf) "{{{1
	if a:tab
		exe "noa tabn" a:tab
	endif
	exe ':noa ' . bufwinnr(a:buf) . 'wincmd w'
endfun

fun! <sid>RecalculateLineNumbers(instn, adjust) "{{{1
	" This only matters, if the original window isn't protected
	if !exists("g:nrrw_rgn_protect") || g:nrrw_rgn_protect !~# 'n'
		return
	endif

	for instn in filter(keys(s:nrrw_rgn_lines), 'v:val != a:instn')
		" Skip narrowed instances, when they are before
		" the region, we are currently putting back
		if s:nrrw_rgn_lines[instn].start[1] <=
		\ s:nrrw_rgn_lines[a:instn].start[1]
			" Skip this instn
			continue
		else 
		   let s:nrrw_rgn_lines[instn].start[1] += a:adjust
		   let s:nrrw_rgn_lines[instn].end[1]   += a:adjust

		   if s:nrrw_rgn_lines[instn].start[1] < 1
			   let s:nrrw_rgn_lines[instn].start[1] = 1
		   endif
		   if s:nrrw_rgn_lines[instn].end[1] < 1
			   let s:nrrw_rgn_lines[instn].end[1] = 1
		   endif
		   call <sid>DeleteMatches(instn)
		   call <sid>AddMatches(<sid>GeneratePattern(
				\s:nrrw_rgn_lines[instn].start[1:2], 
				\s:nrrw_rgn_lines[instn].end[1:2], 
				\'V'), instn)
		endif
	endfor

endfun

fun! <sid>NrrwSettings(on) "{{{1
	if a:on
		setl noswapfile buftype=acwrite bufhidden=wipe foldcolumn=0
		setl nobuflisted
	else
		setl swapfile buftype= bufhidden= buflisted
	endif
endfun

fun! <sid>SetupBufLocalCommands(visual, close) "{{{1
	exe 'com! -buffer -bang WidenRegion :call nrrwrgn#WidenRegion('. a:visual.
		\ ', <bang>0, '. a:close. ')'
	com! -buffer NRSyncOnWrite  :call nrrwrgn#ToggleSyncWrite(1)
	com! -buffer NRNoSyncOnWrite :call nrrwrgn#ToggleSyncWrite(0)
endfun

fun! <sid>ReturnComments() "{{{1
	let cmt = <sid>ReturnCommentFT()
	let c_s    = split(cmt)[0]
	let c_e    = (len(split(cmt)) == 1 ? "" : " " . split(cmt)[1])
	return [c_s, c_e]
endfun

fun! nrrwrgn#NrrwRgnDoPrepare(...) "{{{1
	let bang = (a:0 > 0 && !empty(a:1))
	if !exists("s:nrrw_rgn_line")
		call <sid>WarningMsg("You need to first select the lines to".
			\ " narrow using :NRP!")
	   return
	endif
	if empty(s:nrrw_rgn_line)
		call <sid>WarningMsg("No lines selected from :NRP, aborting!")
	   return
	endif
	if !exists("s:nrrw_rgn_buf")
		let s:nrrw_rgn_buf =  <sid>ParseList(s:nrrw_rgn_line)
	endif
	let o_lz = &lz
	let s:o_s  = @/
	set lz
	let orig_buf=bufnr('')

	" initialize Variables
	call <sid>Init()
    call <sid>CheckProtected()
	let s:nrrw_rgn_lines[s:instn].start		= []
	let s:nrrw_rgn_lines[s:instn].end		= []
	let s:nrrw_rgn_lines[s:instn].multi     = s:nrrw_rgn_buf
	let s:nrrw_rgn_lines[s:instn].orig_buf  = orig_buf
	call <sid>DeleteMatches(s:instn)

	let nr=0
	let lines=[]
	let buffer=[]

	let keys = keys(s:nrrw_rgn_buf)
	call sort(keys,"<sid>CompareNumbers")
	"for [ nr,lines] in items(s:nrrw_rgn_buf)
	let [c_s, c_e] =  <sid>ReturnComments()
	for nr in keys
		let lines = s:nrrw_rgn_buf[nr]
		let start = lines[0]
		let end   = len(lines)==2 ? lines[1] : lines[0]
		call <sid>AddMatches(<sid>GeneratePattern([start,0], [end,0], 'V'),
				\s:instn)
		call add(buffer, c_s.' Start NrrwRgn'.nr.c_e)
		let buffer = buffer +
				\ getline(start,end) +
				\ [c_s.' End NrrwRgn'.nr.c_e, '']
	endfor

	let win=<sid>NrwRgnWin()
	exe ':noa ' win 'wincmd w'
	let b:orig_buf = orig_buf
	call setline(1, buffer)
	setl nomod
	let b:nrrw_instn = s:instn
	call <sid>SetupBufLocalCommands(0, bang)
	call <sid>NrrwRgnAuCmd(0)
	call <sid>CleanRegions()
	call <sid>HideNrrwRgnLines()

	" restore settings
	let &lz   = o_lz
endfun

fun! nrrwrgn#NrrwRgn(...) range  "{{{1
	let o_lz = &lz
	let s:o_s  = @/
	set lz
	let orig_buf=bufnr('')
	let bang = (a:0 > 0 && !empty(a:1))

	" initialize Variables
	call <sid>Init()
    call <sid>CheckProtected()
	let first = a:firstline
	let last  = a:lastline
	" If first line is in a closed fold,
	" include complete fold in Narrowed window
	if first == last && foldclosed(first) != -1
		let first = foldclosed(first)
		let last  = foldclosedend(last)
	endif
	let s:nrrw_rgn_lines[s:instn].start = [ 0, first, 0, 0 ]
	let s:nrrw_rgn_lines[s:instn].end	= [ 0, last , 0, 0 ]
	let s:nrrw_rgn_lines[s:instn].orig_buf  = orig_buf
	let a=getline(
		\s:nrrw_rgn_lines[s:instn].start[1], 
		\s:nrrw_rgn_lines[s:instn].end[1])
	call <sid>DeleteMatches(s:instn)
	if bang
		try
			let local_options = <sid>GetOptions(s:opts)
			" enew fails, when no new unnamed buffer can be edited
			enew
			exe 'f' s:nrrw_winname . '_' . s:instn
			call <sid>SetOptions(local_options)
			call <sid>NrrwSettings(1)
			" succeeded to create a single window
			let s:nrrw_rgn_lines[s:instn].single = 1
		catch /^Vim\%((\a\+)\)\=:E37/	" catch error E37
			" Fall back and use a new window
			" Set the highlighting
			call <sid>AddMatches(<sid>GeneratePattern(
				\s:nrrw_rgn_lines[s:instn].start[1:2], 
				\s:nrrw_rgn_lines[s:instn].end[1:2], 
				\'V'), s:instn)
			let win=<sid>NrwRgnWin()
			exe ':noa ' win 'wincmd w'
		endtry
	else
		" Set the highlighting
		call <sid>AddMatches(<sid>GeneratePattern(
			\s:nrrw_rgn_lines[s:instn].start[1:2], 
			\s:nrrw_rgn_lines[s:instn].end[1:2], 
			\'V'), s:instn)
		let win=<sid>NrwRgnWin()
		exe ':noa ' win 'wincmd w'
	endif
	let b:orig_buf = orig_buf
	call setline(1, a)
	setl nomod
	let b:nrrw_instn = s:instn
	call <sid>SetupBufLocalCommands(0, bang)
	call <sid>NrrwRgnAuCmd(0)
	if has_key(s:nrrw_aucmd, "create")
		exe s:nrrw_aucmd["create"]
	endif
	if has_key(s:nrrw_aucmd, "close")
		let b:nrrw_aucmd_close = s:nrrw_aucmd["close"]
	endif

	" restore settings
	let &lz   = o_lz
endfun

fun! nrrwrgn#Prepare() "{{{1
	let ltime = localtime()
	if  (!exists("s:nrrw_rgn_last") || s:nrrw_rgn_last + 10 < ltime)
		let s:nrrw_rgn_last = ltime
		let s:nrrw_rgn_line = []
	endif
	if !exists("s:nrrw_rgn_line") | let s:nrrw_rgn_line=[] | endif
	call add(s:nrrw_rgn_line, line('.'))
endfun

fun! nrrwrgn#WidenRegion(vmode, force, close) "{{{1
	" a:close: original narrowed window is going to be closed
	" so, clean up, don't renew highlighting, etc.
	let nrw_buf  = bufnr('')
	let orig_buf = b:orig_buf
	let orig_tab = tabpagenr()
	let instn    = b:nrrw_instn
	" Execute autocommands
	if has_key(s:nrrw_aucmd, "close")
		exe s:nrrw_aucmd["close"]
	endif
	let cont	 = getline(1,'$')

	let tab=<sid>BufInTab(orig_buf)
	if tab != tabpagenr() && tab > 0
		exe "tabn" tab
	endif
	let orig_win = bufwinnr(orig_buf)
	" Should be in the right tab now!
	if (orig_win == -1)
		if bufexists(orig_buf)
			exe orig_buf "b!"
		else
			call s:WarningMsg("Original buffer does no longer exist!".
						\ " Aborting!")
			return
		endif
	else
		exe ':noa' . orig_win . 'wincmd w'
	endif
	call <sid>SaveRestoreRegister(1)
	let wsv=winsaveview()
	call <sid>DeleteMatches(instn)
	if exists("b:orig_buf_ro") && b:orig_buf_ro && !a:force
		call s:WarningMsg("Original buffer protected. Can't write changes!")
		call <sid>JumpToBufinTab(orig_tab, nrw_buf)
		return
	endif
	if !&l:ma && !( exists("b:orig_buf_ro") && b:orig_buf_ro)
		setl ma
	endif
	" This is needed to adjust all other narrowed regions
	" in case we have several narrowed regions within the same buffer
	if exists("g:nrrw_rgn_protect") && g:nrrw_rgn_protect =~? 'n'
		let  adjust_line_numbers = len(cont) - 1 - (
					\s:nrrw_rgn_lines[instn].end[1] - 
					\s:nrrw_rgn_lines[instn].start[1])
	endif

	" Make sure the narrowed buffer is still valid (happens, when 2 split
	" window of the narrowed buffer is opened.
	if !has_key(s:nrrw_rgn_lines, instn)
		call <sid>WarningMsg("Error writing changes back,".
					\ "Narrowed Window invalid!")
		return
	endif

	" Now copy the content back into the original buffer

	" 1) Check: Multiselection
	if has_key(s:nrrw_rgn_lines[instn], 'multi')
		call <sid>WidenRegionMulti(cont, instn, a:close)
	" 2) Visual Selection
	elseif a:vmode
		"charwise, linewise or blockwise selection 
		call setreg('a', join(cont, "\n") . "\n",
					\ s:nrrw_rgn_lines[instn].vmode)
		if s:nrrw_rgn_lines[instn].vmode == 'v' &&
			\ s:nrrw_rgn_lines[instn].end[1] -
			\ s:nrrw_rgn_lines[instn].start[1] + 1 == len(cont) + 1
		   " in characterwise selection, remove trailing \n
		   call setreg('a', substitute(@a, '\n$', '', ''), 
			\ s:nrrw_rgn_lines[instn].vmode)
		endif
		if v:version > 703 || (v:version == 703 && has("patch590"))
			" settable '< and '> marks
			let _v = []
			" store actual values
			let _v = [getpos("'<"), getpos("'>"), [visualmode(1)]]
			" set the mode for the gv command
			exe "norm! ". s:nrrw_rgn_lines[instn].vmode."\<ESC>"
			call setpos("'<", s:nrrw_rgn_lines[instn].start)
			call setpos("'>", s:nrrw_rgn_lines[instn].end)
			exe 'norm! gv"aP'
			if !empty(_v[2][0]) && (_v[2][0] != visualmode())
				exe 'norm!' _v[2][0]. "\<ESC>"
				call setpos("'<", _v[0])
				call setpos("'>", _v[1])
			endif
		else
			exe "keepj" s:nrrw_rgn_lines[instn].start[1]
			exe "keepj norm!" s:nrrw_rgn_lines[instn].start[2] . '|'
			exe "keepj norm!" s:nrrw_rgn_lines[instn].vmode
			exe "keepj" s:nrrw_rgn_lines[instn].end[1]
			if s:nrrw_rgn_lines[instn].blockmode
				exe "keepj norm!" s:nrrw_rgn_lines[instn].end[2] . '|'
			else
				keepj norm! $
			endif
			" overwrite the visually selected region with the contents from
			" the narrowed buffer
			norm! "aP
		endif
		" Recalculate the start and end positions of the narrowed window
		" so subsequent calls will adjust the region accordingly
		let [ s:nrrw_rgn_lines[instn].start, 
			 \s:nrrw_rgn_lines[instn].end ] = <sid>RetVisRegionPos()
		" make sure the visual selected lines did not add a new linebreak,
		" this messes up the characterwise selected regions and removes lines
		" on further writings
		if s:nrrw_rgn_lines[instn].end[1] - s:nrrw_rgn_lines[instn].start[1]
				\ + 1 >	len(cont) && s:nrrw_rgn_lines[instn].vmode == 'v'
			let s:nrrw_rgn_lines[instn].end[1] =
				\ s:nrrw_rgn_lines[instn].end[1] - 1
			let s:nrrw_rgn_lines[instn].end[2] = virtcol('$')
		endif

		" also, renew the highlighted region
		if !a:close
			call <sid>AddMatches(<sid>GeneratePattern(
				\ s:nrrw_rgn_lines[instn].start[1:2],
				\ s:nrrw_rgn_lines[instn].end[1:2],
				\ s:nrrw_rgn_lines[instn].vmode),
				\ instn)
		endif
	" 3) :NR started selection
	else 
		" linewise selection because we started the NarrowRegion with the
		" command NarrowRegion(0)
		"
		" if the endposition of the narrowed buffer is also the last line of
		" the buffer, the append will add an extra newline that needs to be
		" cleared.
		if s:nrrw_rgn_lines[instn].end[1]==line('$') &&
		\  s:nrrw_rgn_lines[instn].start[1] == 1
			let delete_last_line=1
		else
			let delete_last_line=0
		endif
		exe ':silent :'.s:nrrw_rgn_lines[instn].start[1].','
			\.s:nrrw_rgn_lines[instn].end[1].'d _'
		call append((s:nrrw_rgn_lines[instn].start[1]-1),cont)
		" Recalculate the start and end positions of the narrowed window
		" so subsequent calls will adjust the region accordingly
		" so subsequent calls will adjust the region accordingly
		let  s:nrrw_rgn_lines[instn].end[1] =
			\ s:nrrw_rgn_lines[instn].start[1] + len(cont) -1
		if s:nrrw_rgn_lines[instn].end[1] > line('$')
			let s:nrrw_rgn_lines[instn].end[1] = line('$')
		endif
		if !a:close
			call <sid>AddMatches(<sid>GeneratePattern(
				\s:nrrw_rgn_lines[instn].start[1:2], 
				\s:nrrw_rgn_lines[instn].end[1:2], 
				\'V'),
				\instn)
		endif
		if delete_last_line
			silent! $d _
		endif
	endif
	" Recalculate start- and endline numbers for all other Narrowed Windows.
	" This matters, if you narrow different regions of the same file and
	" write your changes back.
	if exists("g:nrrw_rgn_protect") && g:nrrw_rgn_protect =~? 'n'
		call <sid>RecalculateLineNumbers(instn, adjust_line_numbers)
	endif
	if a:close && !has_key(s:nrrw_rgn_lines[instn], 'single')
		" For narrowed windows that have been created using !,
		" don't clean up yet, or else we loose all data and can't write
		" it back later.
		" (e.g. :NR! createas a new single window, do :sp
		"  and you can only write one of the windows back, the other will
		"  become invalid, if CleanUp is executed)
		call <sid>CleanUpInstn(instn)
	endif
	call <sid>SaveRestoreRegister(0)
	let  @/=s:o_s
	call winrestview(wsv)
	" jump back to narrowed window
	call <sid>JumpToBufinTab(orig_tab, nrw_buf)
	setl nomod
	if a:force
		" execute auto command
		bw
	endif
endfun

fun! nrrwrgn#VisualNrrwRgn(mode, ...) "{{{1
	" bang: open the narrowed buffer in the current window and don't open a
	" new split window
	if empty(a:mode)
		" in case, visual mode wasn't entered, visualmode()
		" returns an empty string and in that case, we finish
		" here
		call <sid>WarningMsg("There was no region visually selected!")
		return
	endif
	" This beeps, when called from command mode
	" e.g. by using :NRV, so using :sil!
	" else exiting visual mode
	exe "sil! norm! \<ESC>"
	let bang = (a:0 > 0 && !empty(a:1))
	" stop visualmode
	let o_lz = &lz
	let s:o_s  = @/
	set lz
	call <sid>Init()
	let s:nrrw_rgn_lines[s:instn].vmode=a:mode
	" Protect the original buffer,
	" so you won't accidentally modify those lines,
	" that will later be overwritten
	let orig_buf=bufnr('')
	call <sid>SaveRestoreRegister(1)

	call <sid>CheckProtected()
	let [ s:nrrw_rgn_lines[s:instn].start,
		\s:nrrw_rgn_lines[s:instn].end ] = <sid>RetVisRegionPos()
	call <sid>DeleteMatches(s:instn)
	norm! gv"ay
	if len(split(@a, "\n", 1)) != 
			\ (s:nrrw_rgn_lines[s:instn].end[1] -
			\ s:nrrw_rgn_lines[s:instn].start[1] + 1)
		" remove trailing "\n"
		let @a=substitute(@a, '\n$', '', '') 
	endif

	if a:mode == '' && <sid>CheckRectangularRegion(@a)
		" Rectangular selection
		let s:nrrw_rgn_lines[s:instn].blockmode = 1
	else
		" Non-Rectangular selection
		let s:nrrw_rgn_lines[s:instn].blockmode = 0
	endif
	if bang
		try
			let local_options = <sid>GetOptions(s:opts)
			" enew fails, when no new unnamed buffer can be edited
			enew
			exe 'f' s:nrrw_winname . '_' . s:instn
			call <sid>SetOptions(local_options)
			call <sid>NrrwSettings(1)
			" succeeded to create a single window
			let s:nrrw_rgn_lines[s:instn].single = 1
		catch /^Vim\%((\a\+)\)\=:E37/	" catch error E37
			" Fall back and use a new window
			" Set the highlighting
			call <sid>AddMatches(<sid>GeneratePattern(
					\s:nrrw_rgn_lines[s:instn].start[1:2],
					\s:nrrw_rgn_lines[s:instn].end[1:2],
					\s:nrrw_rgn_lines[s:instn].vmode, 
					\s:nrrw_rgn_lines[s:instn].blockmode),
					\s:instn)
			let win=<sid>NrwRgnWin()
			exe ':noa ' win 'wincmd w'
		endtry
	else
		call <sid>AddMatches(<sid>GeneratePattern(
				\s:nrrw_rgn_lines[s:instn].start[1:2],
				\s:nrrw_rgn_lines[s:instn].end[1:2],
				\s:nrrw_rgn_lines[s:instn].vmode, 
				\s:nrrw_rgn_lines[s:instn].blockmode),
				\s:instn)
		let win=<sid>NrwRgnWin()
		exe ':noa ' win 'wincmd w'
	endif
	let b:orig_buf = orig_buf
	let s:nrrw_rgn_lines[s:instn].orig_buf  = orig_buf
	silent put a
	let b:nrrw_instn = s:instn
	silent 0d _
	setl nomod
	call <sid>SetupBufLocalCommands(1,bang)
	" Setup autocommands
	call <sid>NrrwRgnAuCmd(0)
	" Execute autocommands
	if has_key(s:nrrw_aucmd, "create")
		exe s:nrrw_aucmd["create"]
	endif
	call <sid>SaveRestoreRegister(0)

	" restore settings
	let &lz   = o_lz
endfun

fun! nrrwrgn#UnifiedDiff() "{{{1
	let save_winposview=winsaveview()
	let orig_win = winnr()
	" close previous opened Narrowed buffers
	silent! windo | if bufname('')=~'^Narrow_Region' &&
			\ &diff |diffoff|q!|endif
	" minimize Window
	" this is disabled, because this might be useful, to see everything
	"exe "vert resize -999999"
	"setl winfixwidth
	" move to current start of chunk of unified diff
	if search('^@@', 'bcW') > 0
		call search('^@@', 'bc')
	else
		call search('^@@', 'c')
	endif
	let curpos=getpos('.')
	for i in range(2)
		if search('^@@', 'nW') > 0
			.+,/@@/-NR
		else
			" Last chunk in file
			.+,$NR
		endif
	   " Split vertically
	   wincmd H
	   if i==0
		   silent! g/^-/d _
	   else
		   silent! g/^+/d _
	   endif
	   diffthis
	   0
	   exe ":noa wincmd p"
	   call setpos('.', curpos)
	endfor
	call winrestview(save_winposview)
endfun

fun! nrrwrgn#ToggleSyncWrite(enable) "{{{1
	let s:nrrw_rgn_lines[b:nrrw_instn].disable = !a:enable
	" Enable syncing of bufers
	if a:enable
		" Enable Narrow settings and autocommands
		call <sid>NrrwSettings(1)
		call <sid>NrrwRgnAuCmd(0)
		setl modified
	else
		" Disable Narrow settings and autocommands
		call <sid>NrrwSettings(0)
		" b:nrrw_instn should always be available
		call <sid>NrrwRgnAuCmd(b:nrrw_instn)
	endif
endfun

fun! nrrwrgn#LastNrrwRgn(bang) "{{{1
	let bang = !empty(a:bang)
    if !has_key(s:nrrw_rgn_lines, 'last')
		call <sid>WarningMsg("There is no last region to re-select")
	   return
	endif
	let orig_buf = s:nrrw_rgn_lines['last'][0][0] + 0
	let tab = <sid>BufInTab(orig_buf)
	if tab != tabpagenr() && tab > 0
		exe "tabn" tab
	endif
	let orig_win = bufwinnr(orig_buf)
	" Should be in the right tab now!
	if (orig_win == -1)
		call s:WarningMsg("Original buffer does no longer exist! Aborting!")
		return
	endif
	if orig_win != winnr()
		exe "noa" orig_win "wincmd w"
	endif
	if len(s:nrrw_rgn_lines['last']) == 1
		" Multi Narrowed
		let s:nrrw_rgn_buf =  s:nrrw_rgn_lines['last'][0][1]
		call nrrwrgn#NrrwRgnDoPrepare('')
	else
		exe "keepj" s:nrrw_rgn_lines['last'][0][1]
		exe "keepj norm!" s:nrrw_rgn_lines['last'][0][2] . '|'
		exe "keepj norm!" s:nrrw_rgn_lines['last'][2]
		exe "keepj" s:nrrw_rgn_lines['last'][1][1]
		if col(s:nrrw_rgn_lines['last'][1][2]) == col('$') &&
		\ s:nrrw_rgn_lines['last'][2] == ''
			" Best guess
			exe "keepj $"
		else
			exe "keepj norm!" s:nrrw_rgn_lines['last'][1][2] . '|'
		endif
		" Call VisualNrrwRgn()
		call nrrwrgn#VisualNrrwRgn(visualmode(), bang)
	endif
endfu
" Debugging options "{{{1
fun! nrrwrgn#Debug(enable) "{{{1
	if (a:enable)
		let s:debug=1
		fun! <sid>NrrwRgnDebug() "{{{2
			"sil! unlet s:instn
			com! NI :call <sid>WarningMsg("Instance: ".s:instn)
			com! NJ :call <sid>WarningMsg("Data: ".string(s:nrrw_rgn_lines))
			com! -nargs=1 NOutput :if exists("s:".<q-args>)|redraw!|
						\ :exe 'echo s:'.<q-args>|else|
						\ echo "s:".<q-args>. " does not exist!"|endif
		endfun
		call <sid>NrrwRgnDebug()
	else
		let s:debug=0
		delf <sid>NrrwRgnDebug
		delc NI
		delc NJ
		delc NOutput
	endif
endfun

" Modeline {{{1
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0
doc/NarrowRegion.txt	[[[1
523
*NrrwRgn.txt*   A Narrow Region Plugin (similar to Emacs)

Author:  Christian Brabandt <cb@256bit.org>
Version: 0.29 Mon, 20 Aug 2012 19:34:23 +0200
Copyright: (c) 2009, 2010, 2011, 2012 by Christian Brabandt         
           The VIM LICENSE applies to NrrwRgnPlugin.vim and NrrwRgnPlugin.txt
           (see |copyright|) except use NrrwRgnPlugin instead of "Vim".
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.


==============================================================================
1. Contents                                     *NarrowRegion*  *NrrwRgnPlugin*

        1.  Contents.....................................: |NrrwRgnPlugin|
        2.  NrrwRgn Manual...............................: |NrrwRgn-manual|
        2.1   NrrwRgn Howto..............................: |NR-HowTo|
        2.2   NrrwRgn Multi..............................: |NR-multi-example|
        2.3   NrrwRgn Configuration......................: |NrrwRgn-config|
        3.  NrrwRgn Feedback.............................: |NrrwRgn-feedback|
        4.  NrrwRgn History..............................: |NrrwRgn-history|

==============================================================================
2. NrrwRgn Manual                                       *NrrwRgn-manual*

Functionality

This plugin is based on a discussion in comp.editors (see the thread at
http://groups.google.com/group/comp.editors/browse_frm/thread/0f562d97f80dde13)

Narrowing means focussing on a region and making the rest inaccessible. You
simply select the region, call |:NarrowRegion| and the selected part will open
in a new scratch buffer. The rest of the file will be protected, so you won't
accidentally modify that buffer. In the new buffer, you can do a global
replace, search or anything else to modify that part. When you are finished,
simply write that buffer (e.g. by |:w|) and your modifications will be put in
the original buffer making it accessible again.

NrrwRgn allows you to either select a line based selection using an Ex-command
or you can simply use any visual selected region and press your preferred key
combination to open that selection in a new buffer.

This plugin defines the following commands:

                                                        *:NarrowRegion* *:NR*
:[range]NR[!]
:[range]NarrowRegion[!]     When [range] is omitted, select only the current
                            line, else use the lines in the range given and 
                            open it in a new Scratch Window.
                            If the current line is selected and is on a folded
                            region, select the whole folded text.
                            Whenever you are finished modifying that region
                            simply write the buffer.
                            If ! is given, open the narrowed buffer not in a
                            split buffer but in the current window.

                                                        *:NarrowWindow* *:NW*
:NW[!]
:NarrowWindow[!]            Select only the range that is visible the current
                            window and open it in a new Scratch Window. 
                            Whenever you are finished modifying that region
                            simply write the buffer.
                            If ! is given, open the narrowed buffer not in a
                            split buffer but in the current window.

                                                                *:WidenRegion*
:WidenRegion[!]             This command is only available in the narrowed 
                            scratch window. If the buffer has been modified,
                            the contents will be put back on the original
                            buffer. If ! is specified, the window will be
                            closed, otherwise it will remain open.

                                                                        *:NRV*
:NRV[!]                     Opened the narrowed window for the region that was
                            last selected in visual mode
                            If ! is given, open the narrowed buffer not in a
                            split buffer but in the current window.

                                                                        *:NUD*

:NUD                        When viewing unified diffs, this command opens
                            the current chunk in 2 Narrowed Windows in
                            |diff-mode| The current chunk is determined as the
                            one, that the cursor is at. This command does not
                            make sense if editing a different file format (or
                            even different diff format)

                                                                  *:NRPrepare*
:[range]NRPrepare[!]
:[range]NRP[!]              You can use this command, to mark several lines
                            that will later be put into a Narrowed Window
                            using |:NRM|.
                            If the ! is used, all earlier selected lines will
                            be cleared first.

                                                                  *:NRMulti*
:NRMulti
:NRM                        This command takes all lines, that have been
                            marked by |:NRP| and puts them together in a new
                            narrowed buffer.
                            When you write your changes back, all separate
                            lines will be put back at their origin.
                            This command also clears the list of marked lines,
                            that was created with |NRP|.
                            See also |NR-multi-example|.

                                                    *:NRSyncOnWrite* *:NRS*
:NRSyncOnWrite
:NRS                        Enable synching the buffer content back to the
                            original buffer when writing.
                            (this is the default).

                                                    *:NRNoSyncOnWrite* *:NRN*
:NRNoSyncOnWrite
:NRN                        Disable synching the buffer content back to the
                            original buffer when writing. When set, the
                            narrowed buffer behaves like an ordinary buffer
                            that you can write in the filesystem.
                            (this is the default).

                                                                    *:NRL*
                
:NRL[!]                     Reselect the last selected region again and open in
                            a narrowed window. 
                            If ! is given, open the narrowed buffer not in a
                            split buffer but in the current window.


2.1 NrrwRgn HowTo                                                *NR-HowTo*
-----------------

Use the commands provided above to select a certain region to narrow. You can
also start visual mode and have the selected region being narrowed. In this
mode, NarrowRegion allows you to block select |CTRL-V| , character select |v|
or linewise select |V| a region. Then press <Leader>nr where <Leader> by
default is set to '\', unless you have set it to something different (see
|<Leader>| for information how to change this) and the selected range will
open in a new scratch buffer. This key combination only works in |Visual-mode|

When finished, simply write that Narrowed Region window, from which you want
to take the modifications in your original file.

It is possible, to recursively open a Narrowed Window on top of an already
narrowed window. This sounds a little bit silly, but this makes it possible,
to have several narrowed windows, which you can use for several different
things, e.g. If you have 2 different buffers opened and you want to diff a
certain region of each of those 2 buffers, simply open a Narrowed Window for
each buffer, and execute |:diffthis| in each narrowed window.

You can then interactively merge those 2 windows. And when you are finished,
simply write the narrowed window and the changes will be taken back into the
original buffer.

When viewing unified diffs, you can use the provided |:NUD| command to open 2
Narrowed Windows side by side viewing the current chunk in |diff-mode|. Those
2 Narrowed windows will be marked 'modified', since there was some post
processing involved when opening the narrowed windows. Be careful, when
quitting the windows, not to write unwanted changes into your patch file! In
the window that contains the unified buffer, you can move to a different
chunk, run |:NUD| and the 2 Narrowed Windows in diff mode will update.

2.2 NrrwRgn Multi                                    *NR-multi-example*
-----------------

Using the commands |:NRP| and |:NRM| allows to select a range of lines, that
will be put into a narrowed buffer together. This might sound confusing, but
this allows to apply a filter before making changes. For example before
editing your config file, you decide to strip all comments for making big
changes but when you write your changes back, these comments will stay in your
file. You would do it like this: >
    :v/^#/NRP
    :NRMulti
< 
Now a Narrowed Window will open, that contains only the configuration lines.
Each block of independent region will be separated by a string like

# Start NarrowRegion1
.....
# End NarrowRegion1

This is needed, so the plugin later knows, which region belongs where in the
original place. Blocks you don't want to change, you can safely delete, they
won't be written back into your original file. But other than that, you
shouldn't change those separating lines.

When you are finished, simply write your changes back.

==============================================================================

2.3 NrrwRgn Configuration                                    *NrrwRgn-config*
-------------------------

NarrowRegion can be customized by setting some global variables. If you'd
like to open the narrowed window as a vertical split buffer, simply set the
variable g:nrrw_rgn_vert to 1 in your |.vimrc| >

    let g:nrrw_rgn_vert = 1
<
------------------------------------------------------------------------------

If you'd like to specify a certain width/height for you scratch buffer, then
set the variable g:nrrw_rgn_wdth in your |.vimrc| . This variable defines the
width or the nr of columns, if you have also set g:nrrw_rgn_vert. >

    let g:nrrw_rgn_wdth = 30
<
------------------------------------------------------------------------------

By default, NarrowRegion highlights the region that has been selected
using the WildMenu highlighting (see |hl-WildMenu|). If you'd like to use a
different highlighting, set the variable g:nrrw_rgn_hl to your preferred
highlighting Group. For example to have the region highlighted like a search
result, you could put that in your |.vimrc| >

    let g:nrrw_rgn_hl = 'Search'
<
If you want to turn off the highlighting (because this can be distracting), you
can set the global variable g:nrrw_rgn_nohl to 1 in your |.vimrc| >

    let g:nrrw_rgn_nohl = 1
<
------------------------------------------------------------------------------

If you'd like to change the key combination that starts the Narrowed Window
for your selected range, you could put this in your |.vimrc| >

   xmap <F3> <Plug>NrrwrgnDo
<
This will let <F3> open the Narrow-Window, but only if you have pressed it in
Visual Mode. It doesn't really make sense to map this combination to any other
mode, unless you want it to Narrow your last visually selected range.

------------------------------------------------------------------------------

If you'd like to specify the options that you want to have set for the
narrowed window, you can set the g:nrrw_custom_options setting, in your
|.vimrc| e.g. >

   let g:nrrw_custom_options={}
   let g:nrrw_custom_options['filetype'] = 'python'
>
This will only apply those options to the narrowed buffer. You need to take
care that all options you need will apply.

------------------------------------------------------------------------------

If you don't like that your narrowed window opens above the current window,
define the g:nrrw_topbot_leftright variable to your taste, e.g. >

  let g:nrrw_topbot_leftright = 'botright'
<
Now, all narrowed windows will appear below the original window. If not
specified, the narrowed window will appear above/left of the original window.

------------------------------------------------------------------------------

If you want to use several independent narrowed regions of the same buffer
that you want to write at the same time, protecting the original buffer is not
really useful. Therefore, set the g:nrrw_rgn_protect variable, e.g. in your
|.vimrc| >
  
   let g:nrrw_rgn_protect = 'n'
<
This can be useful if you diff different regions of the same file, and want
to be able to put back the changes at different positions. Please note that
you should take care not to change any part that will later be influenced
when writing the narrowed region back.

Note: Don't use overlapping regions! Your changes will probably not be put
back correctly and there is no guard against losing data accidentally. NrrwRgn
tries hard to adjust the highlighting and regions as you write your changes
back into the original buffer, but it can't guarantee that this will work and
might fail silently. Therefore, this feature is experimental!

------------------------------------------------------------------------------
                                                                    *NR-hooks*

NarrowRegion can execute certain commands, when creating the narrowed window
and when closing the narrowed window. For this, you can set 2 buffer-local
variables that specify what commands to execute, which will hook into the
execution of the Narrow Region plugin.

For example, suppose you have a file, containing columns separated data (CSV
format) which you want to modify and you also have the CSV filetype plugin
(http://www.vim.org/scripts/script.php?script_id=2830) installed and you want
to modify the CSV data which should be visually arranged like a table in the
narrowed window. 

Therefore you want the command |:ArrangeColumn| to be executed in the new
narrowed window upon entering it, and when writing the changes back, you want
the command |:UnArrangeColumn| to be executed just before putting the
changes back. So you set those two variables in your original buffer: >

    let b:nrrw_aucmd_create = "set ft=csv|%ArrangeCol"
    let b:nrrw_aucmd_close  = "%UnArrangeColumn"
<
This will execute the commands in the narrowed window: >

    :set ft=csv
    :%ArrangeCol

and before writing the changes back, it'll execute: >
    
    :%UnArrangeCol

==============================================================================
3. NrrwRgn Feedback                                         *NrrwRgn-feedback*

Feedback is always welcome. If you like the plugin, please rate it at the
vim-page:
http://www.vim.org/scripts/script.php?script_id=3075

You can also follow the development of the plugin at github:
http://github.com/chrisbra/NrrwRgn

Please don't hesitate to report any bugs to the maintainer, mentioned in the
third line of this document.

If you like the plugin, write me an email (look in the third line for my mail
address). And if you are really happy, vote for the plugin and consider
looking at my Amazon whishlist: http://www.amazon.de/wishlist/2BKAHE8J7Z6UW

==============================================================================
4. NrrwRgn History                                          *NrrwRgn-history*


0.29: Aug 20, 2012 {{{1
- Use ! to have the narrowed buffer not opened in a new window (suggested by
  Greg Sexton thanks!, issue #8
  https://github.com/chrisbra/NrrwRgn/issues/8)
- Fix mappings for visual mode (https://github.com/chrisbra/NrrwRgn/issues/9,
  reported by Sung Pae, thanks!)
- Fix problem with setting the filetype
  (https://github.com/chrisbra/NrrwRgn/issues/10, reported by Hong Xu,
  thanks!)
- Fix some minor problems, when using ! mode
0.28: Jun 03, 2012 {{{1
- Plugin did not store last narrowed region when narrowed window was moved to
  another tabpage (reported by Ben Fritz, thanks!)

0.27: May 17, 2012 {{{1
- When using |:NR| on a line that is folded, include the whole folded region
  in the Narrowed window.
- Better filetype detection for comments
- Error handling, when doing |:NRM| without doing |:NRP| first
- Use |:NRP!| to clear the old selection
- Don't load the autoload script when sourcing the plugin script
  (reported by Sergey Khorev, thanks!)
- Vim 7.3.449 introduced E855, prevent this error.
- |:NRL|
- |NRM| did not correctly parse the list of lines provided by |:NRP|
- highlighted pattern for blockwise visual narrowed regions was wrong
- Saving blockwise visual selected regions back, could corrupt the contents

0.26: Jan 02, 2012 {{{1

- Fix issue https://github.com/chrisbra/NrrwRgn/issues/7
  (reported by Alessio B., thanks!)


0.25: Nov 08, 2011 {{{1

- updated documentation (patch by Jean, thanks!)
- make it possible, to not sync the narrowed buffer back by disabling
  it using |:NRSyncOnWrite| |:NRNoSyncOnWrite|

0.24: Oct 24, 2011 {{{1

- error on vim.org page, reuploaded version 0.22 as 0.24

0.23: Oct 24, 2011 {{{1

- (wrongly uploaded to vim.org)
  
0.22: Oct 24, 2011 {{{1

- Allow customization via the use of hooks (|NR-hooks|)

0.21: July 26, 2011 {{{1

- Fix undefined variable adjust_line_numbers
  https://github.com/chrisbra/NrrwRgn/issues/5 (reported by jmcantrell,
  thanks!)

0.20: July 25, 2011 {{{1
- allow customization via the g:nrrw_topbot_leftright variable (Thanks Herbert
  Sitz!)
- allow what options will be applied using the g:nrrw_custom_options dict
  (suggested by Herbert Sitz. Thanks!)
- NRV didn't hightlight the region that was selected (reported by Herbert
  Sitz, thanks!)
- use the g:nrrw_rgn_protect variable, to prevent that the original buffer
  will be protected. This is useful, if you narrow several regions of the same
  buffer and want to write those changes indepentently (reported by kolyuchiy
  in https://github.com/chrisbra/NrrwRgn/issues/3, Thanks!)
- fix an error with not correctly deleting the highlighted region, that was
  discovered when reporting issue 3 (see above). (Reported by kolyuchiy,
  thanks!)
- Catch errors, when setting window local options. (Patch by Sung Pae,
  Thanks!)

0.19: May 22, 2011 {{{1
- fix issue 2 from github https://github.com/chrisbra/NrrwRgn/issues/2
  (Widening does not work, if the narrowed windows have been moved to a new
  tabspace). Reported by vanschelven, thanks!

0.18: December 10, 2010 {{{1
- experimental feature: Allow to Narrow several different regions at once
  using :g/pattern/NRP and afterwards calling :NRM
  (This only works linewise. Should that be made possible for any reagion?)
- disable folds, before writing changes back, otherwise chances are, you'll
  lose more data then wanted
- code cleanup

0.17: November 23, 2010 {{{1
- cache the options, that will be set (instead of parsing
  $VIMRUNTIME/doc/options.txt every time) in the Narrowed Window
- getting the options didn't work, when using an autocommand like this:
  autocmd BufEnter * cd %:p:h
  (reported by Xu Hong, Thanks!)
- :q didn't clean up the Narrowed Buffer correctly. Fix this
- some code cleanup

0.16: November 16, 2010 {{{1
- Bugfix: copy all local options to the narrowed window (reported by Xu Hong,
  Thanks!)

0.15: August 26, 2010 {{{1
- Bugfix: minor documentation update (reported by Hong Xu, Thanks!)

0.14: August 26, 2010 {{{1
- Bugfix: :only in the original buffer resulted in errors (reported by Adam
  Monsen, Thanks!)

0.13: August 22, 2010 {{{1
- Unified Diff Handling (experimental feature)

0.12: July 29, 2010 {{{1

- Version 0.11, wasn't packaged correctly and the vimball file
  contained some garbage. (Thanks Dennis Hostetler!)

0.11: July 28, 2010 {{{1

- Don't set 'winfixwidth' and 'winfixheight' (suggested by Charles Campbell)

0.10: May 20, 2010 {{{1

- Restore cursor position using winrestview() and winsaveview()
- fix a bug, that prevented the use of visual narrowing
- Make sure when closing the narrowed buffer, the content will be written to
  the right original region
- use topleft for opening the Narrowed window
- check, that the original buffer is still available
- If you Narrow the complete buffer using :NRV and write the changes back, an
  additional trailing line is inserted. Remove that line.
- When writing the changes back, update the highlighting.

0.9: May 20, 2010 {{{1

- It is now possible to Narrow a window recursively. This allows to have
  several narrowed windows, and allows for example to only diff certain
  regions (as was suggested in a recent thread at the vim_use mailinglist:
  http://groups.google.com/group/vim_use/msg/05d7fd9bd1556f0e) therefore, the
  use for the g:nrrw_rgn_sepwin variable isn't necessary anymore.
- Small documentation updates

0.8: May 18, 2010 {{{1

- the g:nrrw_rgn_sepwin variable can be used to force separate Narrowed
  Windows, so you could easily diff those windows.
- make the separating of several windows a little bit safer (look at the
  bufnr(), so it should work without problems for several buffers)
- switch from script local variables to buffer local variables, so narrowing
  for several buffers should work.
- set 'winfixheight' for narrowed window 
- Added command :NRV (suggested by Charles Campbell, thanks!)
- added error handling, in case :NRV is called, without a selected region
- take care of beeps, when calling :NRV
- output WarningMsg

0.7: May 17, 2010 {{{1

- really use the black hole register for deleting the old buffer contents in
  the narrowed buffer (suggestion by esquifit in
  http://groups.google.com/group/comp.editors/msg/3eb3e3a7c68597db)
- make autocommand nesting, so the highlighting will be removed when writing
  the buffer contents.
- Use g:nrrw_rgn_nohl variable to disable highlighting (as this can be
  disturbing).

0.6: May 04, 2010 {{{1

- the previous version had problems restoring the orig buffer, this version
  fixes it (highlighting and setl ma did not work correctly)

0.5: May 04, 2010 {{{1

- The mapping that allows for narrowing a visually selected range, did not
  work.  (Fixed!)
- Make :WidenRegion work as expected (close the widened window) (unreleased)

0.4: Apr 28, 2010 {{{1

- Highlight narrowed region in the original buffer
- Save and Restore search-register
- Provide shortcut commands |:NR| 
- Provide command |:NW| and |:NarrowWindow|
- Make plugin autoloadable
- Enable GLVS (see |:GLVS|)
- Provide Documenation (:h NarrowRegion)
- Distribute Plugin as vimball |pi_vimball.txt|

0.3: Apr 28, 2010 {{{1

- Initial upload
- development versions are available at the github repository
- put plugin on a public repository (http://github.com/chrisbra/NrrwRgn)

  }}}

==============================================================================
Modeline:
vim:tw=78:ts=8:ft=help:et:fdm=marker:fdl=0:norl
