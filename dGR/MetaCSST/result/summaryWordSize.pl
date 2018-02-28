#!/usr/bin/perl -w
use strict;

my ($gtf,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <GTF File> <OUT File>\n" if (@ARGV<2);
open(GTF,$gtf)||die("error\n");
open(OUT,">$out")||die("error\n");

print OUT "ID\tTR_string\tTR_start\tTR_end\tTR_seq\tVR_string\tVR_start\tVR_end\tVR_seq\tA-to-N\tNon-A-to-N\tMax_continuous_consistent_segment\n";

my @TR = ();
while(<GTF>){
    chomp();
    my @data = split(/\s+/,$_);
    if($data[1] eq "TR"){
	@TR = @data;
    }
    elsif($data[1] eq "VR" && $data[7]+$data[8]>0){	
	my @VR = @data;
	my @mut = ();
	push(@mut,-1);
	my $len = length($VR[9]);
	for(my $i=0;$i<$len;$i++){
	    my $char1 = substr($TR[9],$i,1);
	    my $char2 = substr($VR[9],$i,1);
	    if($char1 ne $char2){
		push(@mut,$i);
	    }
	}
	
	push(@mut,length($VR[9])-1);

	my $word = 0;
	for(my $i=1;$i < @mut;$i++){
	    my $tmp = $mut[$i]-$mut[$i-1]-1;
	    if($tmp > $word){
		$word = $tmp;
	    }
	}
	print OUT "$VR[0]\t$TR[2]\t$TR[5]\t$TR[6]\t$TR[9]\t$VR[2]\t$VR[5]\t$VR[6]\t$VR[9]\t$VR[7]\t$VR[8]\t$word\n";
    }
}

close GTF;close OUT;
exit;
