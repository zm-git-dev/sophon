#!/usr/bin/perl -w
use strict;

#This script is used to get the hit ORFs

my ($hit,$pro,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <ORF-1st.info> <ORF.pro> <OUT File>\n" if (@ARGV<3);
open(HIT,$hit)||die("error\n");
open(OUT,">$out")||die("error\n");
open(PRO,$pro)||die("error\n");

my %hash = ();
while(<HIT>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash{$arr[0]} = 1;
}

my $id = "";
while(<PRO>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	if(exists($hash{$id})){
	    print OUT ">$id\n$_\n";
	}
    }
}

close HIT;close PRO;close OUT;
exit;
