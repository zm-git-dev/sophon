#!/usr/bin/perl -w
use strict;

###This script is to find the significant genes/isoforms according to the fold change value and the corresponding gene/isoform number

my ($file)= @ARGV;
die "Error with arguments!\nusage: $0 <gene/transcript.diff(/pvalue/qvalue)>" if (@ARGV<1);

my $out = $file.".count";

my $fold_change = 2;
my $down_fold_change = 0.5;
open(FILE,$file)||die("error with opening $file\n");
open(OUT,">$out")||die("error with writing to $out\n");

print OUT "ID\tUP\tDOWN\n";

while(<FILE>){
    chomp();
    if($_ !~ /WGC/){
	my @arr = split(/\s+/,$_);
	my ($up,$down) = (0,0);
	for(my $i=1;$i<@arr;$i++){
	    if($arr[$i] ne "." && $arr[$i] ne "*" && $arr[$i] ne "-"){
		if($arr[$i] eq "inf" || $arr[$i] >= $fold_change){
		    $up += 1;
		}
		elsif($arr[$i] <= $down_fold_change){
		    $down += 1;
		}
	    }
	}
	print OUT "$arr[0]\t$up\t$down\n";
    }
    next;
}

close FILE;close OUT;
exit;
