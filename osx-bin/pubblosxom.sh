#!/bin/sh

mkdir -p ~/vimwiki_html/
cd ~/vimwiki/

wikifiles=( *.wiki )

for filename in "${wikifiles[@]}"; do
    cat "$filename" | Markdown.pl > /Library/WebServer/Documents/blosxom/"$filename"
done
