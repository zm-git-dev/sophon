#!/usr/bin/perl -w
use strict;

#This script is used to merge the DGR information,including the position, structure and sample information

my ($pos,$stru,$sample,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <DGR.txt(position)> <structure2.txt> <sample.info> <OUT File>\n" if (@ARGV<4);

open(POS,$pos)||die("error\n");
open(STRU,$stru)||die("error\n");
open(SAMPLE,$sample)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash_stru = ();my %hash_sample = ();
while(<STRU>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash_stru{$arr[0]} = $arr[1];
}

while(<SAMPLE>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash_sample{$arr[0]} = $arr[1];
}

while(<POS>){
    chomp();
    my @arr = split(/\;/,$_);
    my $id = $arr[0];
    print OUT "$id;$arr[1];$arr[2];$hash_sample{$id};$hash_stru{$id}\n";
}


close POS;close OUT;close STRU;close SAMPLE;
exit;
