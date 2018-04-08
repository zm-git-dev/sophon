#!/usr/bin/perl -w
use strict;

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Input Sam File> <OUT File>\n" if (@ARGV<2);

#my $tmp = $file."tmp";
#system("samtools view $file > $tmp");

#open(FILE,$tmp)||die("error\n");
open(FILE,$file)||die("error\n");
open(OUT,">$out-tmp")||die("error\n");

while(<FILE>){
    chomp($_);
    my @data = split(/\s+/,$_);
    if($data[0] ne "\@HD" && $data[0] ne "\@PG" && $data[5] ne '*' ){
	my ($id,$start,$info) = ($data[2],$data[3]-1,$data[5]);
	my @match = $info =~ /(\d+)M/g;
	my @deletion = $info =~ /(\d+)D/g;
	my $len = 0;
	foreach my $i(@match){
	    $len += $i;
	}
	foreach my $i(@deletion){
	    $len += $i;
	}
	my $end = $start+$len-1;
	print OUT "$id\t$start\t$end\n";
    }
}

close FILE;close OUT;
system("sort -k1,1 -k2n,2 -k3n,3 $out-tmp >$out");

system("rm $out-tmp");
exit;
