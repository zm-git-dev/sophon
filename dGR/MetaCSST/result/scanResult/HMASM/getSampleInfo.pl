#!/usr/bin/perl -w
use strict;

my (@files)= @ARGV;
die "Error with arguments!\nusage: $0 <GTF Files>\n" if (@ARGV<1);
foreach my $file(@files){
    my $id = "";
    if($file =~ /(SRS\d+)\.gtf/){
	$id = $1;
	open(FILE,$file);
	while(<FILE>){
	    chomp($_);
	    if($_ =~ /\sDGR\s/){
		my @arr = split(/\s+/,$_);
		print "$arr[0]\t$id\n";
	    }
	}
    }
}
exit;
