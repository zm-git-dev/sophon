#!/usr/bin/perl -w
use strict;

#This program is used to get data with cassette as well as phylum

my ($cassette,$phylum,$group,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Cassette classification> <Phylum classification> <Cassette Group> <OUT File>\n" if (@ARGV<4);

open(FILE1,$cassette)||die("error\n");
open(FILE2,$phylum)||die("error\n");
open(OUT,">$out")||die("error\n");

my %CASSETTE = ();
while(<FILE1>){
    chomp();
    my @arr = split(/\s+/,$_);
    $CASSETTE{$arr[0]} = $arr[1];
}

print OUT "ID\tCassette\tPhylum\n";
while(<FILE2>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($CASSETTE{$arr[0]} eq $group){
	print OUT "$arr[0]\t$arr[1]\t$group\n";
    }
    else{
	print OUT "$arr[0]\t$arr[1]\tNon-$group\n"
    }
    #print OUT "$arr[0]\t$arr[1]\t$CASSETTE{$arr[0]}\n";
}

close FILE1;close FILE2;
exit;
