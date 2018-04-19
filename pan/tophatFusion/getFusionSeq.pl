#!/usr/bin/perl -w
use strict;

my ($fusion,$gene,$fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <17fusion.info> <geneInfo.out> <GRCh38.p10.fa> <OUT File>\n" if (@ARGV<4);

open(FUSION,$fusion)||die("error\n");
open(GENE,$gene)||die("error\n");
open(FA,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

my %genome_hash = ();
my %gene_hash = ();

my $id = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+/){
	$id = $1;
    }
    else{
	$genome{$id} = $_;
    }
}

while(<GENE>){
    chomp();
    my @arr = split(/\s+/,$_);
    $gene_hash{$arr[0]} = $_;
}

while(<FUSION>){
    chomp();
}


close FUSION;close FA;close GENE;close OUT;
exit;
