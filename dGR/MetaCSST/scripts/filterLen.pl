#!/usr/bin/perl -w
use strict;

my ($cuttof) = @ARGV;
open(FILE,"pair.txt")||die("error\n");

while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    if(length($arr[9]) < $cuttof){
	print "$arr[0]\t$arr[1]\t$arr[2]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$arr[9]\n";
    }
}
