#!/usr/bin/perl -w
use strict;

#This script is used to split the total data to some classes according to the k-means clusters

my ($file,$class,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Total Fasta DataSet> <ID classify File> <OutFile>\n" if (@ARGV<3);

open(FILE,$file)||die("error with opening $file\n");
open(CLASS,$class)||die("error with opening $class\n");
open(OUT,">$out")||die("error with writing to $out");

my @seq = ();
my @id = ();

while(<FILE>){
    chomp();
    if($_ =~ />([^\s]+)/){
	push(@id,$1);
    }
    else{
	push(@seq,$_);
    }
    next;
}

while(<CLASS>){
    chomp();
    if($_ =~ /(\d+)/){
        my $num = $1-1;
	print OUT ">$id[$num]\n$seq[$num]\n";
    }
    next;
}

close FILE;close CLASS;close OUT;
exit;
