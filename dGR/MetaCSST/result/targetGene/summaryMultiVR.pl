#!/usr/bin/perl -w
use strict;

#This scripts is summarize the multiVRs overlap infomation

my ($overlap,$id,$out)= @ARGV;
die("usage: $0 <VR-ORF Overlap info> <MultiVR.id> <OUT File>\n") if (@ARGV<3);

open(IN,$overlap)||die("error\n");
open(ID,$id)||die("error\n");
open(OUT,">$out")||die("error\n");

my %vr = ();
while(<ID>){
    chomp();
    my @data = split(/\s+/,$_);
    $vr{$data[0]} = $data[1];
}

my %gene = ();
my %target = ();
my %vr_withORF = ();

while(<IN>){
    chomp();
    my @data = split(/\s+/,$_);
    if(exists($vr{$data[0]})){
	print OUT "$_\n";

	if(not exists($vr_withORF{$data[0]})){
	    $vr_withORF{$data[0]} = 1;
	}
	else{
	    $vr_withORF{$data[0]} += 1;
	}

	if(not exists($gene{$data[4]})){
	    $gene{$data[4]} = 1;
	    if(not exists($target{$data[0]})){
		$target{$data[0]} = 1;
	    }
	    else{
		$target{$data[0]} += 1;
	    }
	}
    }
}


print "ID\tVR_number\tVR_with_ORF_number\tORF_number\n";
foreach my $key(keys %vr){
    if(exists($target{$key})){
	print "$key\t$vr{$key}\t$vr_withORF{$key}\t$target{$key}\n";
    }
    else{
	print "$key\t$vr{$key}\t0\t0\n";
    }
}

close IN;close OUT;close ID;
exit;
