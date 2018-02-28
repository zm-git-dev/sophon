#!/usr/bin/perl -w
use strict;

#This script is used to summarize the DGR length

my ($gtf,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <GTF File> <OUT File>\n" if (@ARGV<2);
open(GTF,$gtf)||die("error\n");
open(OUT,">$out")||die("error\n");

my ($id,$start,$end) = ("",10000000000,-1);

print OUT "ID\tstart\tend\tlen\n";
my $len = 0;
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[0] ne $id){
	if($end != -1){
	    $len = $end-$start+1;
	    print OUT "$id\t$start\t$end\t$len\n";
	}
	$id = $arr[0];
	($start,$end) = (10000000000,-1);
    }
    if($arr[1] eq "TR" || $arr[1] eq "VR"){
	if($arr[5] < $start){$start = $arr[5];}
	if($arr[6] > $end){$end = $arr[6];}
    }
    elsif($arr[1] eq "RT"){
	if($arr[3] < $start){$start = $arr[3];}
        if($arr[4] > $end){$end = $arr[4];}
    }
}

print OUT "$id\t$start\t$end\t$len\n";

exit;
