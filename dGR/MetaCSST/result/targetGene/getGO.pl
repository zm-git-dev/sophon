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

my $num = keys %gene;
print "$num\n";

my $hitID = "";
$num = 0 ;
while(<GO>){
    chomp();
    #if($_ =~ />([^\s]+)\s+.+\s+symbol:([^\s]+)/){
    if($_ =~ />([^\s]+)/){
	$hitID = $1;
	if(exists($gene{$hitID}) && $_ =~ /symbol:([^\s]+)/){
	    $num ++;
	    my $symbol = $1;
	    #print OUT "$hitID\t$symbol\n";
	    my @GO = $_ =~ /GO:(\d+)/g;
	    foreach my $id(@GO){
		print OUT "$symbol\tGO:$id\n";
	    }
	}
    }
    next;
}

print "$num\n";
close HIT;close GO;close OUT;
exit;
