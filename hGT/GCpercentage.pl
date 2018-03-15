#!/usr/bin/perl -w
use strict;

## compare the A,T,C,G percentage of the genome and putative HGT sequences

my ($fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <seq.fa> <OUT File>\n" if (@ARGV<2);
open(FA,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

my $id = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	if($_ =~ /[ATCGatcg]/){
	    my ($A,$T,$C,$G) = GCpercentage($_);
	    print OUT "$id\t$A\t$T\t$C\t$G\n";
	}
    }
}

sub GCpercentage{
    my ($seq) = @_;
    my ($A,$T,$C,$G) = (0,0,0,0);
    my $len = length($seq);
    for(my $i=0;$i<$len;$i++){
	my $base = substr($seq,$i,1);
	if($base eq 'A' || $base eq 'a'){
	    $A += 1;
	}
	elsif($base eq 'T' || $base eq 't'){
	    $T += 1;
	}
	elsif($base eq 'C' || $base eq 'c'){
	    $C += 1;
	}
	elsif($base eq 'G' || $base eq 'g'){
	    $G += 1;
	}
    }
    my $all = $A+$T+$C+$G;
    $A = sprintf("%0.2f",$A/$all);
    $T = sprintf("%0.2f",$T/$all);
    $C = sprintf("%0.2f",$C/$all);
    $G = sprintf("%0.2f",$G/$all);
    return ($A,$T,$C,$G);
}

close FA;close OUT;
exit;
