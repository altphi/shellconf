#!/bin/sh
rm -f /Library/WebServer/Documents/wiki.local/*.html
rm -f /Library/WebServer/Documents/wiki.local/*.rss
perl ~/bin/blosxom.cgi -password='static-please'
