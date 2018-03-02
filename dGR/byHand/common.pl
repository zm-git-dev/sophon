#!/usr/bin/perl -w 
use strict;

#This script is used to get the common ids from two files

my (@files) = @ARGV;
die "Error with arguments!\nusage: $0 <ID Files>\n" if (@ARGV<2);

my %count = ();
foreach my $file(@files){
    open(FILE,$file)||die("error\n");
    while(<FILE>){
	chomp();
	my $id=$_;
	#if($_ =~ /(Sample_WGC\d+R)/){
	 #   $id = $1;
	#}
	if(not exists($count{$id})){
	    $count{$id} = 1;
	}
	else{
	    $count{$id} += 1;
	}
	next;
    }
    close FILE;
}

foreach my $key(keys %count){
    print "$key\t$count{$key}\n";
}

exit;
