#!/usr/bin/perl -w
use strict;

#get regions conserved in non-mammal genomes, overlapped sequences >= 500bp && at least two non-mammal species sharing this region

my (@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Filtered out files of non-mammal genomes> \n" if (@ARGV<1);

my %total = ();

for my $file(@files){
    open(FILE,$file)||die("error\n");
    my %hash = ();
    print "$file\n";
    while(<FILE>){
	my @arr = split(/\s+/,$_);
	my ($seq,$start,$end) = ($arr[0],$arr[6],$arr[7]);
	if($end < $start){
	    my $tmp = $start;
	    $start = $end;
	    $end = $tmp;
	}
	if(not exists($hash{$seq})){
	    my @cov = ();
	    for(my $i=0;$i<1000;$i++){
		push(@cov,0);
	    }
	    for(my $i=$start-1;$i<$end;$i++){
		$cov[$i] = 1;
	    }
	    $hash{$seq} = \@cov;
	}
	else{
	    for(my $i=$start-1;$i<$end;$i++){
		${hash{$seq}}[$i] = 1;
	    }
	}
    }
    close FILE;
    foreach my $key(keys %hash){
	if(not exists $total{$key}){
	    $total{$key} = $hash{$key};
	}
	else{
	    for(my $i=0;$i<1000;$i++){
		${total{$key}}[$i] = ${total{$key}}[$i] + $hash{$key}[$i];
	    }
	}
    }
}

foreach my $key(keys %total){
    my @start = ();
    my @end = ();
    for(my $i=0;$i<1000;$i++){
	if(${total{$key}}[$i] >= 2 && ($i ==0 || ${total{$key}}[$i-1] < 2)){
	    push(@start,$i);
	}
	elsif(${total{$key}}[$i] >= 2 && ($i == 999 || ${total{$key}}[$i+1] < 2)){
	    push(@end,$i);
	}
    }
    for(my $i=0;$i<@start;$i++){
	if($end[$i] - $start[$i] >= 500){
	    print "$key\t$start[$i]\t$end[$i]\n";
	}
    }
}

exit;
