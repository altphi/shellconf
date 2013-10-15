#!/bin/sh

if [ $# -lt 1 ] ; then
  echo "usage: $0 wiki_item"; exit 1;
else
fn="/Users/stephen/Documents/vimwiki/${1}.wiki"
cat "$fn" | while read ln ; do
ln=`echo "$ln" | sed 's/^[[:space:]]*//g'`;
ln=`echo "$ln" | tr -s ' '`;
echo "\"`echo "$ln" | cut -d\; -f2 | sed 's/^[[:space:]]*//g'`\", \"`echo "$ln" | cut -d\; -f1 | sed 's/^[[:space:]]*//g'`\"";
done
fi
