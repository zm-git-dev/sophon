#!/usr/bin/perl -w
use strict;

my ($id,$file)= @ARGV;
die "Error with arguments!\nusage: $0 <Non-redundant IDs> <cov.txt>\n" if (@ARGV<2);

open(ID,$id)||die("erron\n");
my %unique = ();
while(<ID>){
    chomp();
    $unique{$_} = 1;
}

print "ID\tReads\tLen\tCov\n";

open(FILE,$file)||die("error\n");
while(<FILE>){
    chomp($_);
    if($_ !~ /id;/){
	my @arr = split(/\s+/,$_);
	if(exists($unique{$arr[0]})){
	    print "$_\n";
	}
    }
}

close ID;close FILE;
exit;
