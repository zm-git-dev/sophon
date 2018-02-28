#!/usr/bin/perl -w
use strict;

#This scripts is used to get the unique VRs, and th overlapped VRs will be merged and only retain one copy

my ($vr,$out)= @ARGV;
die("usage: $0 <VR.info> <OUT File>\n") if (@ARGV<2);

open(VR,$vr)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
while(<VR>){
    chomp();
    my @data = split(/\s+/,$_);
    my $id = $data[0];
    if(not exists($hash{$id})){
	$hash{$id} = 1;
    }
    else{
	$hash{$id} += 1;
    }
}

foreach my $key(keys %hash){
    if($hash{$key} != 1){
	print OUT "$key\t$hash{$key}\n";
    }
}

close VR;close OUT;
exit;
