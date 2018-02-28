#!/usr/bin/perl -w
use strict;

my ($hit,$go,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <hitGO.id> <GO Database> <OUT File>\n" if (@ARGV<3);
open(HIT,$hit)||die("error\n");
open(GO,$go)||die("error\n");
open(OUT,">$out")||die("Error\n");

my %gene = ();

while(<HIT>){
    chomp();
    $gene{$_} = 1;
    next;
}

my $hitID = "";
while(<GO>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$hitID = $1;
	if($_ =~ /Uniprot:([^\s]+)/){
	    if(exists($gene{$hitID})){
		my $uniprot = $1;
		#print OUT "$hitID\t$uniprot\n";
		my @GO = $_ =~ /\[GO:(\d+)/g;
		foreach my $id(@GO){
		    print OUT "$uniprot\tGO:$id\n";
		}
	    }
	}
    }
    next;
}

close HIT;close GO;close OUT;
exit;
