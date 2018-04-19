#!/usr/bin/perl -w
use strict;

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <summaryHTML-3.out> <OUT File>\n" if (@ARGV<2);
open(FILE,$file)||die("error\n");
open(OUT,">$out")||die("error\n");

my %tumor = ();
my %nomal = ();
my %pos_number = ();
my %pos = ();
my %sample = ();

while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    my $fusion = $arr[1]."|".$arr[4];

    if(not exists($nomal{$fusion})){$nomal{$fusion} = 0;}
    if(not exists($tumor{$fusion})){$tumor{$fusion} = 0;}

    my $fusion_sample = $arr[1]."|".$arr[4]."|".$arr[0];
    if($arr[0] eq "WGC017519R" || $arr[0] eq "WGC017518R"){
	if(not exists($sample{$fusion_sample})){
	    $nomal{$fusion} += 1;
	    $sample{$fusion_sample} = 1;
	}
    }
    else{
	if(not exists($sample{$fusion_sample})){
	    $tumor{$fusion} += 1;
	    $sample{$fusion_sample} = 1;
	}
    }

    my $fusion_pos = $arr[1]."|".$arr[3]."|".$arr[4]."|".$arr[6]."|".$arr[10];
    if(not exists($pos_number{$fusion})){
	$pos_number{$fusion} = 1;
	$pos{$fusion_pos} = 1;
    }
    else{
	if(not exists($pos{$fusion_pos})){
	    $pos_number{$fusion} += 1;
	    $pos{$fusion_pos} = 1;
	}
    }
}

print OUT "#gene_fusion\tnormal_sample\ttumor_sample\tfusion_pos_number\n";
foreach my $fusion(keys %pos_number){
    print OUT "$fusion\t$nomal{$fusion}\t$tumor{$fusion}\t$pos_number{$fusion}\n";
}

close FILE;close OUT;
exit;
