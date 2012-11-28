#!/bin/sh
if [ $# -lt 2 ]; then
        echo "usage: $0 s/from/to pattern"; exit 1;
fi

realIFS=$IFS;
IFS='
';

ls -1 | grep -e $2 | while read file; do
	newname=`echo "$file" | sed -e $1;`
	echo "moving $file to $newname..."
	mv $file $newname
done

IFS=$realIFS;
