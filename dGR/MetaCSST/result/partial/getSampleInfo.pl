#!/usr/bin/perl -w
use strict;

my (@files)= @ARGV;
die "Error with arguments!\nusage: $0 <SRS*.gtf>\n" if (@ARGV<1);

my $sample = "";
print "ID\tSample\n";
foreach my $file(@files){
    if($file =~ /(SRS\d+)\.gtf/){
	$sample = $1;
    }
    open(FILE,$file);    
    while(<FILE>){
	chomp($_);
	if($_ =~ /DGR/){
	    my @arr = split(/\s+/,$_);
	    print "$arr[0]\t$sample\n";
	}
    }
    close FILE;
}

exit;
