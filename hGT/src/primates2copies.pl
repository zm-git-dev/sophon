#!/usr/bin/perl -w
use strict;

my ($hit,$bed,$out)=@ARGV;
die "Error with arguments!\nusage: $0 <summaryHit.txt> <screenHGT-8mammals.bed> <OUT File>" if (@ARGV<3);

open(HIT,$hit)||die("error with opening $hit\n");
open(BED,$bed)||die("error with opening $bed\n");
open(OUT,">$out")||die("error\n");

print OUT "region\tprimate_percent\tcopies\n";

my %copy = ();
while(<HIT>){
    chomp();
    my @arr  =split(/\s+/,$_);
    $copy{$arr[0]} = $arr[4];
    next;
}

while(<BED>){
    chomp();
    my @arr  =split(/\s+/,$_);
    my $hgt = $arr[0]."-".$arr[1]."-".$arr[2];
    if($arr[3] > 0){
	my $primates_percent = sprintf("%0.3f",$arr[5]/$arr[3]);
	if(exists($copy{$hgt})){
	    print OUT "$hgt\t$primates_percent\t$copy{$hgt}\n";
	}
	else{
	    print OUT "$hgt\t$primates_percent\t0\n";
	}
    }
}


close HIT;close BED;close OUT;
exit;
