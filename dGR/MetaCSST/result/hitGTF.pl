#!/usr/bin/perl -w
use strict;

#This script is used to choose some DGRs according to the ids

my ($gtf,$id,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <GTF File> <ID File> <OUT File>\n" if (@ARGV<3);
open(GTF,$gtf)||die("error\n");
open(OUT,">$out")||die("error\n");
open(ID,$id)||die("error\n");

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
