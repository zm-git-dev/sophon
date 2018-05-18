#!/usr/bin/perl -w
use strict;

my ($hit)= @ARGV;
die "Error with arguments!\nusage: $0 <BLASTN Hit (-outfmt 7)>" if (@ARGV<1);

open(HIT,$hit)||die("error\n with opening $hit");

my $out = "";
my ($query_start,$query_end) = (-1,-1);
while(<HIT>){
    chomp();
    if ($_ =~ /Query: ([^\s]+)/){
	if($out ne ""){
	    close OUT;
	}
	$out = $1;
	if($out =~ /\|(\d+)-(\d+)/){
	    ($query_start,$query_end) = ($1,$2);
	}
	open(OUT,">hit/$out.txt")||die("error with writing to $out\n");
    }
    elsif($_ !~ /\#/){
	my @arr = split(/\s+/,$_);
	my ($chr,$identity,$start,$end) = ($arr[1],$arr[2],$arr[8],$arr[9]);
	if($end < $start){
	    my $tmp = $end;
	    $end = $start;
	    $start = $tmp;
	}
	if($start >= $query_end || $end <= $query_start){
	    print OUT "$chr\t$start\t$end\t$identity\n";
	}
    }
    next;
}

close HIT;close OUT;
exit;
