#!/usr/bin/perl -w
use strict;

#This script is used to call the sequences that maybe contain a DGR form the HMASM assembly dataset

my ($ref,$file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Ref Sequence> <Result File In GTF Format> <OUT File>\n" if (@ARGV<3);

open(OUT,">$out")||die("Error with writing to $out\n");

my %genome = ();
my ($name,$sequence) = ("","");
open(REF,$ref)||die("Error with opening $ref\n");
while(<REF>){
    chomp();
    if($_ =~ />([^\s]+)/){$name = $1;}
    elsif($_ =~ /[^\s]/){
	$sequence = $_;
	if(not exists($genome{$name})){$genome{$name} = $sequence;}
    }
    next;
}
close REF;

my %index = ();
open(FILE,$file)||die("Error with opening $file\n");
while(<FILE>){
    chomp();
    if($_ =~ /DGR/){
	my @data = split(/\s+/,$_);
	my $id = $data[0];
	if(not exists($index{$id})){
	    if(exists($genome{$id})){
		print OUT ">$id\n$genome{$id}\n";
	    }
	    $index{$id} = 1;
	}
    }
    next;
}
close FILE;

close OUT;
exit;
