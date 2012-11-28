augroup filetypedetect
au BufNewFile,BufRead php*.conf,webdav.conf,davuser*.conf,redirect*conf	setf apachestyle
augroup END
