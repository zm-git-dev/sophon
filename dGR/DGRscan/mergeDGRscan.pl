#!/usr/bin/perl -w
use strict;

open(RT,"DGRscanRT.gtf")||die("error with opening RT\n");
open(TRVR,"DGRscanTRVR.gtf")||die("error with opening TRVR\n");
open(OUT,">DGRscan.gtf")||die("error\n");

my %hash = ();
while(<RT>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash{$arr[0]} = $_;
    next;
}

while(<TRVR>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[0] =~ /(.+)_TR1/){
	my $rt = $hash{$1};
	print OUT "$rt\n$_\n";
    }
    else{
	print OUT "$_\n";
    }
    next;
}


close OUT;
exit;
