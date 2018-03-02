#!/usr/bin/perl -w
use strict;

#This script is used to mv the redundant DGRs in the GTF file according to the non-redundant DGR Fasta file

my ($gtf,$fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Merged.gtf> <Non-redundant DGR Fasta File> <OUT File>\n" if (@ARGV<3);

open(FA,$fa)||die("error\n");
open(GTF,$gtf)||die("error with opening $gtf\n");
open(OUT,">$out")||die("error with writing to $out\n");

my %yes = ();
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	my $id = $1;
	$yes{$id} = 1;
    }
}

while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[1] eq "RT"){
	if(exists($yes{$arr[0]})){
	    print OUT "$_\n"
	}
    }
    elsif($arr[1] eq "TR"){
	if($arr[0] =~ /([^\s]+)_TR/){
	    if(exists($yes{$1})){
		print OUT "$_\n"
	    }
	}
    }
    elsif($arr[1] eq "VR"){
        if($arr[0] =~ /([^\s]+)_VR/){
            if(exists($yes{$1})){
                print OUT "$_\n";
            }
        }
	
	next;
    }
}
    
close GTF;close OUT;close FA;
exit;
    
