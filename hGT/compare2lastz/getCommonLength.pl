#!/usr/bin/perl -w
use strict;

my ($bed1,$bed2)= @ARGV;
die "Error with arguments!\nusage: $0 <Bed File1> <Bed File2> (sorted, merged, single chromosome)\n" if (@ARGV<2);

open(FILE1,$bed1)||die("error\n");
open(FILE2,$bed2)||die("error\n");

my $common = 0;
my @lines = <FILE2>;

while(<FILE1>){
    chomp($_);
    my ($chr1,$start1,$end1) = split(/\s+/,$_);
    foreach my $line(@lines){
	chomp($line);
	my ($chr2,$start2,$end2) = split(/\s+/,$line);
	if($end1 <= $start2){
	    last;
	}
	elsif(!($start1 >= $end2)){
	    my ($cov_start,$cov_end) = ($start1,$end1);
	    if($start2 > $start1){
		$cov_start = $start2;
	    }
	    if($end2 < $end1){
		$cov_end = $end2;
	    }
	    $common += $cov_end-$cov_start+1;
	}
    }
}

print "Common coverage: $common bp\n";
close FILE1;close FILE2;
exit;
