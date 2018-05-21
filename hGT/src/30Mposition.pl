#!/usr/bin/perl -w
use strict;

#This program is used to get the position of the sequences, which are merged to generate seg30M

my ($fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <hg19-seg1k-step1k-4mer-pass.fa> <OUT>\n" if (@ARGV<2);

open(FA,$fa)||die("error with opening $fa\n");
open(OUT,">$out")||die("error with writing to $out\n");

my ($id,$index)  = ("",1);
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	my $len = length($_);
	my ($start,$end) = ($index,$index+$len-1);
	print OUT "$id\t$start\t$end\n";
	$index += $len;
    }
}


close FA;close OUT;
exit;
