#!/usr/bin/perl -w
use strict;

#This program is get some records from the whole dataset

my ($csv,$all,$select,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <Dataset,csv format> <line number in the whole dataset> <selected records> <OUT File>\n" if (@ARGV<4);

open(FILE,$csv)||die("error with opeing $csv\n");
open(OUT,">$out")||die("error with writing to $out\n");

my $per = sprintf("%d",$all/$select);

my $num = 1;
while(<FILE>){
    if($num % $per == 1){
	print OUT "$_";
    }
    $num++;
    next;
}

close FILE;close OUT;
exit;
