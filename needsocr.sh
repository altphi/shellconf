#!/bin/sh

pdflist=( ./*.pdf )
mkdir -p NeedsOCR
cd NeedsOCR
for d in "${pdflist[@]}"; do
  if [`pdffonts ../"$d" | wc -l` -lt 3 ] ; then
	ln -s ../"$d" "$d";
  fi
done
