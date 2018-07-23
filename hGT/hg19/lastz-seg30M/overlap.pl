#!/usr/bin/perl -w
use strict;

open(FILE,"overlap.txt")||die("error\n");

while(<FILE>){
    chomp();
    my ($chr,$start1,$end1,$mm,$qq,$start2,$end2) = split(/\s+/,$_);
    if($start2 > $start1){
	$start1 = $start2;
    }
    if($end2 < $end1){
	$end1 = $end2;
    }
    my $overlap = $end1-$start1+1;
    print "$_\t$overlap\n";
}

exit;
