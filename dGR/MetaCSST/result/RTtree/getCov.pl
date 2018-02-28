#!/usr/bin/perl -w
use strict;

my ($id,$cov,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <meta-unique.id> <cov.txt> <OUT File>\n" if (@ARGV<3);

open(COV,$cov)||die("error\n");
open(ID,$id)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
while(<ID>){
    chomp();
    $hash{$_} = 1;
}

while(<COV>){
    chomp();
    my @data = split(/\s+/,$_);
    if(exists($hash{$data[0]})){
	print OUT "$data[0] $data[3]\n";
    }
}

close COV;close ID;close OUT;
exit;
