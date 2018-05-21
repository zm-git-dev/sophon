#!/usr/bin/perl -w
use strict;

my ($fa,$bed,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Genome.fa> <HGT.bed> <OUT File>\n" if (@ARGV<3);
open(FA,$fa)||die("error\n");
open(BED,$bed)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
my $id = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$hash{$id} = $_;
    }
}

while(<BED>){
    chomp();
    my @arr = split(/\s+/,$_);
    #my ($chr,$start,$end) = split(/\s+/,$_);
    my ($chr,$start,$end) = ($arr[0],$arr[1],$arr[2]);
    #if(exists($hash{$chr})){
	my $HGT = substr($hash{$chr},$start-1,$end-$start+1);
	print OUT ">$chr|$start-$end\n$HGT\n";
    #}
}

close FA;close BED;close OUT;
exit;
