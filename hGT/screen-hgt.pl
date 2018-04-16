#!/usr/bin/perl -w
use strict;

my ($hit,$out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <segment hits of BLAST2nonMammal> <OUT File> <BLAST2mammal segments cover FILES>\n" if (@ARGV<3);

open(HIT,$hit)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();

while(<HIT>){
    chomp();
    my @arr = split(/\s+/,$_);
    if(not exists($hash{$arr[0]})){
	my @data = ($arr[1],$arr[2],0);
	$hash{$arr[0]} = \@data;
    }
}

foreach my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    while(<FILE>){
	chomp();
	my ($id,$covSeq) = split(/\s+/,$_);
	if(exists($hash{$id})){
	    my ($start,$end) = (${hash{$id}}[0],${hash{$id}}[1]);
	    my $covLen = 0;
	    my @arr = split(/,/,$covSeq);
	    foreach my $covSeqSub(@arr){
		my ($start_sub,$end_sub) = split(/-/,$covSeqSub);
		if(!($start_sub >= $end || $end <= $start)){
		    my ($cov_start,$cov_end) = (-1,-1);
		    if($start_sub > $start){
			$cov_start = $start_sub;
		    }
		    else{
			$cov_start = $start;
		    }
		    if($end_sub < $end){
			$cov_end = $end_sub;
		    }
                    else{
			$cov_end = $end;
		    }
		    $covLen += $cov_end-$cov_start+1;
		}
	    }
	    if($covLen >= 0.4*($end-$start+1)){
		${hash{$id}}[2] += 1;
	    }
	}
    }
    close FILE;
}

foreach my $key(keys %hash){
    print OUT "$key\t$hash{$key}[0]\t$hash{$key}[1]\t$hash{$key}[2]\n";
}


close HIT;close OUT;
exit;
