#!/usr/bin/perl -w
use strict;

#used to get the included regions

my ($seg,$hgt)= @ARGV;
die "Error with arguments!\nusage: $0 <SEG.info (index reference)> <HGT.info (target)>\n" if (@ARGV<2);
#file format: chr start end  (the file is previously sorted)

open(SEG,$seg)||die("error\n");
open(HGT,$hgt)||die("error\n");

my @data = ();
my $num = 0;
while(<SEG>){
    chomp();
    my @arr = split(/\s+/,$_);
    for(my $j=0;$j<=2;$j++){
	$data[$num][$j] = $arr[$j];
    }
    $num += 1;
    next;
}

while(<HGT>){
    chomp();
    my ($chr,$start,$end) = split(/\s+/,$_);
    for(my $i=0;$i<$num;$i++){
        if($chr eq $data[$i][0] && $start>= $data[$i][1] && $end <= $data[$i][2]){
            print "$_ ;;; $data[$i][0]\t$data[$i][1]\t$data[$i][2]\n";
            last;
        }
    }
}

=pod
my $index = 0;
while(<HGT>){
    chomp();
    my ($chr,$start,$end) = split(/\s+/,$_);
    for(my $i=$index;$i<$num;$i++){
	if($chr lt $data[$i][0] || ($chr eq $data[$i][0] && $end <= $data[$i][1])){
	    $index = $i;
	    last;
	}
	elsif($chr gt $data[$i][0] || $start >= $data[$i][2]){
	    ;
	}
	else{ ##overlapped
	    print "$_ ;;; $data[$i][0]\t$data[$i][1]\t$data[$i][2]\n";
	    $index = $i;
	    last;
	}
    }
}
=cut

exit;
