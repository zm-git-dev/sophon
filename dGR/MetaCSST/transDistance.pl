#!/usr/bin/perl -w
use strict;

#This script is transform the distance result from the result of mafft-distance to a distance matrix

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Distance result by mafft-distance> <Transformed OutFile>\n" if (@ARGV<2);

my @matrix=();

my $len=0;
open(IN,$in)||die("error\n");
open(OUT,">$out")||die("error\n");
while(<IN>){
    chomp;
    if($_ =~ /(\d+)-(\d+)\s+d=([\d\.]+)\s+/){
	my ($id1,$id2,$dis) = ($1,$2,$3);
	if($id2 > $len){$len = $2;}
	$matrix[$id1-1][$id2-1] = $dis;
    }
    next;
}

for(my $i=0;$i<$len;$i++){
    for(my $j=0;$j<$len;$j++){
	if($i == $j){
	    $matrix[$i][$j] = 0;
	}
	elsif($i > $j){
	    $matrix[$i][$j] = $matrix[$j][$i];
	}
    }
}

for(my $i=0;$i<$len;$i++){
    for(my $j=0;$j<$len;$j++){
	if($j == $len-1){
	    print OUT "$matrix[$i][$j]\n";
	}
	else{
	    print OUT "$matrix[$i][$j]\t";
	}
    }
}
exit;

