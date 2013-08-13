
function! VimwikiFoldText()
    let loopy = 0
    let foldstart = v:foldstart
    let linenumb = v:foldstart
    while loopy == 0 && linenumb <= v:foldend
        let line = getline(linenumb)
        let matchtest = matchstr(line,"tags: ")
        if matchtest == "tags: "
            let loopy = 1
        else
            let linenumb = linenumb + 1
        endif
    endwhile
    if loopy == 0
        let line = getline(foldstart)
        let line = substitute(line, "{{{ ", "", "")
    else
        let line = substitute(line, "tags: ", "", "")
    endif
    let linecount = v:foldend - v:foldstart
    return v:folddashes . " " . linecount . " lines: " . line
endfunction
set foldtext=MyFoldText()
