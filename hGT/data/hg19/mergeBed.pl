#!/usr/bin/perl -w
use strict;

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Inout sorted bed file> <OUT File>\n" if (@ARGV<2);

open(FILE,$in)||die("error\n");
open(OUT,">$out")||die("error\n");

my ($chr,$start,$end,$type) = ("",-1,-1,"");
while(<FILE>){
    chomp($_);
    my ($chr1,$start1,$end1,$type1) = split(/\s+/,$_);
    if($chr eq ""){
	($chr,$start,$end,$type) = ($chr1,$start1,$end1,$type1);
    }
    elsif($chr1 ne $chr){
	print OUT "$chr\t$start\t$end\t$type\n";
	($chr,$start,$end) = ($chr1,$start1,$end1);
    }
    else{
	if($start1 > $end +1){
	    print OUT "$chr\t$start\t$end\t$type\n";
	    ($start,$end) = ($start1,$end1);
	}
	elsif($end1 > $end){
	    $end = $end1;
	}
    }
}
print OUT "$chr\t$start\t$end\t$type\n";

close FILE;close OUT;
exit;
