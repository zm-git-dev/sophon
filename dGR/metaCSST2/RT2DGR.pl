#!/usr/bin/perl -w
use strict;

#This script is used to call the DGR sequences in the test or training dataset according to the total DGR data and RT id

my ($RT,$DGR,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <RT.fa> <dataSet/merged.DGR.fa> <OUT File>\n" if (@ARGV<3);
open(DGR,$DGR)||die("error with opening $DGR\n");
open(RT,$RT)||die("error with opening $RT\n");
open(OUT,">$out")||die("error with writing to $out\n");

my %hash = ();
my $id = "";
while(<DGR>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$hash{$id} = $_;
    }
}

while(<RT>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
	print OUT ">$id\n$hash{$id}\n";
    }
}

close DGR;close RT;close OUT;
exit;
