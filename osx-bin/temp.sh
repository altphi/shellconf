#!/bin/sh

cd ~/vimwiki/

orig=$IFS;
IFS='
';
wikifiles=( `find ~/vimwiki -name '*.wiki' -print0 | xargs -0 ls` ); 

for filename in "${wikifiles[@]}"; do
    outputname=`echo "$filename" | sed -e 's/wiki//g'`;
    echo $outputname
    echo
done

IFS=$orig;
