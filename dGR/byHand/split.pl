#!/usr/bin/perl -w
use strict;

#This script is used to split the total data to some classes according to the multiAlignment result(Muscle->FastTreeMP->FigTree)

my ($file,$class,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Total Fasta DataSet> <ID classify File> <OutFile>\n" if (@ARGV<3);

open(FILE,$file)||die("error with opening $file\n");
open(CLASS,$class)||die("error with opening $class\n");
open(OUT,">$out")||die("error with writing to $out");

my %seq = ();
my ($name,$sequence) = ("","");
while(<FILE>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$name = $1;
    }
    else{
	$sequence = $_;
	if(not exists($seq{$name})){
	    $seq{$name} = $sequence;
	}
    }
    next;
}

while(<CLASS>){
    chomp();
    if($_ =~ /([^\s]+)/){
        my $id = $1;
	if(exists($seq{$id})){
	    print OUT ">$id\n$seq{$id}\n";
	}
    }
    next;
}

close FILE;close CLASS;close OUT;
exit;
