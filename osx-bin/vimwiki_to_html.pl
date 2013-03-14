#!/usr/bin/perl

while (<>)
{
    chomp($_);	
    # check for wiki link brackets [[ ]]
	while (/\[\[(.*?)\]\]/)
        { my $link = $1;
          my $href = "<a href=\"http://wiki.local/$link.html\">$link</a>";
          $_ =~ s/\[\[$link\]\]/$href/;
          }

    # insert javascript for folding {{{ }}} blocks 
    while (/\{\{\{(.*?)$/)
        { my $foldtitle = $1;
          $foldtitle =~ s/^\s+//;
          $foldtitle =~ s/\<p\>//;
          $foldtitle =~ s/\<\/p\>//;
          my $newfold = "<h5><a href=\"#\" onclick=\"ns=next(this.parentNode); toggleBlock(ns.id); return false;\">$foldtitle</a></h5>";
          $_ = $newfold . "\n<div id=\"$foldtitle\">"; 
          }

    # add closing </div> in place of }}}
    while (/\}\}\}/)
        { my $closediv = "</div>";
          $_ =~ s/\<p\>//;
          $_ =~ s/\<\/p\>//;
          $_ =~ s/\}\}\}/$closediv/; 
          # $_ = "\r\n\r\n" . $_ . "\r\n\r\n";
          }
    
    # add code to add <br> whenever the line does not end with a <> tag (or just '>' ?)
    if ( ! /.*\>$/ ) { $_ =~ s/$/\<br\>/; } 

    print "$_\n"; 
}
