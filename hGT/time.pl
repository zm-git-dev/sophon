#!/usr/bin/perl -w
use strict;


my ($time,$info,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <time.txt> <info.txt> <OUT>\n" if (@ARGV<3);

open(OUT,">$out")||die("Can't write to $out\n");
open(INFO,$info)||die("Can't open file1\n");
open(TIME,$time)||die("Can't open file2\n");

my %hash =  ();
while(<INFO>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash{$arr[0]} = $arr[1];
}

while(<TIME>){
    chomp();
    my @arr = split(/\s+/,$_);
    print OUT "$arr[0]\t$arr[1]\t$hash{$arr[0]}\n";
}

close OUT;close INFO;close TIME;
exit;
