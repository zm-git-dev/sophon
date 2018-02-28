#!/usr/bin/perl -w
use strict;

#This script is used to get the non_redundant DGRs

my ($gtf,$id,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <all-intact.gtf> <core.id> <OUT File>\n" if (@ARGV<3);
open(ID,$id)||die("error\n");
open(GTF,$gtf)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
while(<ID>){
    chomp();
    $hash{$_} = 1;
}

while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if(exists($hash{$arr[0]})){
	print OUT "$_\n";
    }
}

close ID;close GTF;close OUT;
exit;
