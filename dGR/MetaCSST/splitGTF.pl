#!/usr/bin/perl -w
use strict;

#This script is split the GTF file predicted by MetaCSST
#a completely same TR-VR pair should be retained

my ($gtf,$num,$pre,$dir)= @ARGV;
die "Error with arguments!\nusage: $0 <Result File In GTF Format> <Split number> <Prefix> <OUT Directory>\n" if (@ARGV<4);

system("mkdir $dir");

open(GTF,$gtf)||die("error1\n");

my $line = 0;
my $id = 0;

my $out = $dir."/".$pre."_".$id.".gtf";
open(OUT,">$out")||die("error2\n");

while(<GTF>){
    if($_ =~ /DGR/){
	print OUT "$_";
	$line += 1;
	
	if($line == $num){
	    $id += 1;
	    $line = 0;
	    
	    close OUT;
	    $out = $dir."/".$pre."_".$id.".gtf";
	    open(OUT,">$out")||die("error2\n");
	}
    }
    else{
	print OUT "$_";
    }
}


close GTF;
