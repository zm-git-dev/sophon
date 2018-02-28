#!/usr/bin/perl -w
use strict;

#This scripts is used to get the target gene information (location)

my ($gene,$info,$out)= @ARGV;
die("usage: $0 <targetGene.fa> <ORF.info> <OUT File>\n") if (@ARGV<3);

open(GENE,$gene)||die("error\n");
open(INFO,$info)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
while(<INFO>){
    chomp();
    my @data = split(/\s+/,$_);
    $hash{$data[0]} = "$data[1]\t$data[3]\t$data[4]";
}

while(<GENE>){
    chomp();
    if($_ =~ />([^\s]+)/){
	my $id = $1;
	if(exists($hash{$id})){
	    print OUT ">$id\t$hash{$id}\n";
	}
	else{
	    print "Error\n";
	    last;
	}
    }
    else{
	print OUT "$_\n";
    }
}

close GENE; close INFO; close OUT;
exit;
