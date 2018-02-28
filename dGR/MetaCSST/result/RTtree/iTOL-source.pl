#!/usr/bin/perl -w
use strict;

### iTOL source annotation

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <IN File> <OUT File>\n" if (@ARGV<2);

open(IN,$in)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
$hash{"bactaria_genomes"} = "#FF0000";
$hash{"human_microbiomes"} = "#00DB00";

while(<IN>){
    chomp();
    my @data = split(/\s+/,$_);
    if(exists($hash{$data[1]})){
	print OUT "$data[0] $hash{$data[1]} $data[1]\n";
    }
    else{
	print OUT "$data[0] #0000E3 $data[1]\n";
    }
}

close IN;close OUT;
exit;
