#!/usr/bin/perl -w
use strict;

my ($hit,$out,$cov_cuttof,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Nonmammal conserved regions (bed)> <OUT File> <length coverage cuttof> <Merged mammal files>\n" if (@ARGV<4);

open(HIT,$hit)||die("error\n with opening $hit");
open(OUT,">$out")||die("error with writing to $out\n");

my %hash = ();
while(<HIT>){
    chomp();
    my $key = $_;
    $hash{$key} = 0;
}

foreach my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    my %hashCov = ();
    while(<FILE>){
	chomp();
	my @arr = split(/\s+/,$_);
	$hashCov{$arr[0]} = $arr[1];
    }
    close FILE;

    foreach my $key(keys %hash){
	my ($region,$start,$end) = split(/\s+/,$key);
	if(exists($hashCov{$region})){
	    my $covSeq = $hashCov{$region};
	    my $covLen = 0;
	    my @arr = split(/,/,$covSeq);
	    foreach my $covSeqSub(@arr){
		my ($start_sub,$end_sub) = split(/-/,$covSeqSub);
		if(!($start_sub >= $end || $end_sub <= $start)){
		    my ($cov_start,$cov_end) = ($start,$end);
		    if($start_sub > $start){
			$cov_start = $start_sub;
		    }
		    if($end_sub < $end){
			$cov_end = $end_sub;
		    }
		    $covLen += $cov_end-$cov_start+1;
		}
	    }
	    if($covLen >= $cov_cuttof*($end-$start+1)){
		#push(@{$hash{$key}},$file);
		$hash{$key} += 1;
	    }
	}
    }
}

foreach my $key(keys %hash){
    print OUT "$key\t$hash{$key}\n";
}

close HIT;close OUT;
exit;
