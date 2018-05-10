#!/usr/bin/perl -w
use strict;

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Inout sorted bed file (single chromosome)> <OUT File>\n" if (@ARGV<2);

open(FILE,$in)||die("error\n");
open(OUT,">$out")||die("error\n");

my ($chr,$start,$end) = ("chr21",-1,-1);
while(<FILE>){
    chomp($_);
    my ($chr1,$start1,$end1) = split(/\s+/);
    if($start == -1){
	($start,$end) = ($start1,$end1);
    }
    else{
	if($start1 > $end +1){
	    print OUT "$chr\t$start\t$end\n";
	    ($start,$end) = ($start1,$end1);
	}
	else{
	    $end = $end1;
	}
    }
}
print OUT "$chr\t$start\t$end\n";

close FILE;close OUT;
exit;
