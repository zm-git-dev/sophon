#!/usr/bin/perl -w
use strict;

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <id.txt> <OUT File>\n" if (@ARGV<2);

open(FILE,$file);
open(OUT,">$out");
while(<FILE>){
    chomp($_);
    my $id = $_;
    my $html = "ncbi_html/$id.html";
    open(HTML,$html)||die("error\n");
    while(<HTML>){
	chomp();
	if($_ =~ /ORGANISM=(\d+)&amp/){
	    my $id2 = $1;
	    print OUT "$id\t$id2\n";
	    system("wget https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=$id2 -O $id.html");
	    last;
	}
    }
    close HTML;
}

exit;
