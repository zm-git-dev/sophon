#!/usr/bin/perl -w
use strict;

my ($file,$id,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <targetGene-GO.blastp-uniprot.txt> <Target-background common IDs> <OUT File>\n" if (@ARGV<3);

open(FILE,$file)||die("error\n");
open(ID,$id)||die("error\n");
open(OUT,">$out")||die("Error\n");

my %yes = ();
while(<ID>){
    chomp();
    $yes{$_} = 1;
    next;
}

while(<FILE>){
    chomp();
    my ($uniprot,$GO) = split(/\s+/,$_);
    if(exists($yes{$uniprot})){
	print OUT "$_\n";
    }
}

close FILE;close OUT;close ID;
exit;
