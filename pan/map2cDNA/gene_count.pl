#!/usr/bin/perl -w
use strict;

my ($file)= @ARGV;
die "Error with arguments!\nusage: $0 <summaryCov2.txt>" if (@ARGV<1);
open(FILE,$file)||die("error\n");

while(<FILE>){
    chomp();
    if($_ !~ /Sample/){
	my @data = split(/\s+/,$_);
	my $id = $data[0];
	my $num = 0;
	for(my $i=1;$i<@data;$i++){
	    $num += $data[$i];
	}
	if($num != 0){
	    print "$id\t$num\n";
	}
    }
}

close FILE;
exit;
