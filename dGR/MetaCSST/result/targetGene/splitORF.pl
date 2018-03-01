#!/usr/bin/perl -w
use strict;

#This scripts is used to split ORF.info

my ($orf)= @ARGV;
die("usage: $0 <ORF.info>\n") if (@ARGV<1);

open(IN,$orf)||die("error\n");

my $number = 25;
my $count = 1;
my $out = "ORF-split-".$count.".txt";
open(OUT,">$out")||die("error\n");
my $i = 0;
my %hash = ();
while(<IN>){
    chomp();
    my @arr = split(/\|/,$_);
    my $id = $arr[0];
    if(not exists($hash{$id})){
	if($i >= 25){
	    close OUT;
	    $count += 1;
	    $out = "ORF-split-".$count.".txt";
	    open(OUT,">$out")||die("error\n");
	    $i=0;
	}
	$hash{$id} = 1;
	$i++;
	
    }
    print OUT "$_\n";
}



close IN;close OUT;
exit;
