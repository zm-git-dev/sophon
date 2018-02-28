#!/usr/bin/perl -w
use strict;

#This scripts is used to move overlap redundancy, only the longest overlapped ORF will be retained for each VR

my ($overlap,$out)= @ARGV;
die("usage: $0 <VR-ORF Overlap info> <OUT File>\n") if (@ARGV<2);

open(IN,$overlap)||die("error\n");
open(OUT,">$out")||die("error\n");

my @last = ();
while(<IN>){
    my @data = split(/\s+/,$_);
    if(@last != 0){
	my $VR = $data[0].$data[1].$data[2].$data[3];
	my $VR_last = $last[0].$last[1].$last[2].$last[3];
	if($VR ne $VR_last){
	    print OUT "@last\n";
	    @last = @data;
	}
	else{
	    my $len = abs($data[6]-$data[7]);
	    my $len_last = abs($last[6]-$last[7]);
	    if($len > $len_last){
		@last = @data;
	    }
	}
    }
    else{
	@last = @data;
    }
    next;
}
print OUT "@last\n";

close IN;close OUT;
exit;
