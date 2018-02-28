#!/usr/bin/perl -w
use strict;

my $file = "GI_hv.txt";
open(FILE,$file)||die("Can't open $file\n");

while(<FILE>){
    chomp();
    if($_ =~ /(\d+)/){
	my $gi = $1;
	open(OUT,">GI.txt");
	print OUT "$gi\n";
	system("./DiGReF.pl");
	close OUT;
    }
    next;
}

close FILE;
exit;
