#!/usr/bin/perl -w
use strict;

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <structure1.txt> <OUT File(structure2.txt)>\n" if (@ARGV<2);

open(FILE,$file)||die("error\n");
open(OUT,">$out")||die("error\n");
my $id = "";
my $tmp = "";
while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[0] ne $id){
	if($id ne ""){
	    chop($tmp);
	    print OUT "$tmp\n";
	}
	$tmp = "";
	$id = $arr[0];
	$tmp .= "$id\t".$arr[4].$arr[3].".";
    }
    else{
	$tmp .= $arr[4].$arr[3].".";
    }
}

chop($tmp);
print OUT "$tmp\n";

close FILE;close OUT;
exit;
