#!/usr/bin/perl -w
use strict;

my ($count,$info,$out) = @ARGV;

my %number = ();
my %index = ();
open(INFO,$info);
open(COUNT,$count);
open(OUT,">$out");

while(<INFO>){
    chomp();
    my @arr = split(/\s+/,$_);
    $index{$arr[1]} = $arr[0];
    next;
}


while(<COUNT>){
    chomp();
    my @arr = split(/\s+/,$_);
    my $id = $index{$arr[0]};
    if(not exists($number{$id})){
	$number{$id} = $arr[1];
    }
    else{
	$number{$id} += $arr[1];
    }
}

foreach my $key(keys %number){
    print OUT "$key\t$number{$key}\n";
}
