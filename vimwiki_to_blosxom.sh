#!/bin/sh

cd ~/Documents/vimwiki/
rm -f /Library/WebServer/Documents/blosxom/*txt

wikifiles=( *.wiki );

for filename in "${wikifiles[@]}"; do
    if ! `grep -q '\%nohtml' "$filename"`
    then
        outputname=`echo "$filename" | sed -e 's/wiki//g'`;
        cat "$outputname"wiki | markdown | vimwiki_to_html.pl > /Library/WebServer/Documents/blosxom/"$outputname"txt
        touch -r "$outputname"wiki /Library/WebServer/Documents/blosxom/"$outputname"txt
    else
        echo "skipping $filename"
    fi
done
