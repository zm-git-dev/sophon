#!/usr/bin/perl -w
use strict;

#get regions conserved in non-mammal genomes, overlapped sequences >= 500bp && at least two non-mammal species sharing this region

my ($fa,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Reference fasta file> <Filtered out files of non-mammal genomes> \n" if (@ARGV<2);

open(FA,$fa)||die("error with opening $fa\n");

my %len = ();
my $seq_name = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$seq_name = $1;
    }
    else{
	$len{$seq_name} = length($_);
    }
}

my %total = ();

my $seq_length = 0;
for my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    my %hash = ();
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
	    $seq_length = $len{$seq};
	    for(my $i=0;$i<$seq_length;$i++){
		push(@cov,0);
	    }
	    for(my $i=$start-1;$i<=$end-1;$i++){
		$cov[$i] = 1;
	    }
	    $hash{$seq} = \@cov;
	}
	else{
	    for(my $i=$start-1;$i<=$end-1;$i++){
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
	    $seq_length = $len{$key};
	    for(my $i=0;$i<$seq_length;$i++){
		${total{$key}}[$i] = ${total{$key}}[$i] + $hash{$key}[$i];
	    }
	}
    }
}

foreach my $key(keys %total){
    my @start = ();
    my @end = ();
    $seq_length = $len{$key};
    for(my $i=0;$i<$seq_length;$i++){
	if(${total{$key}}[$i] >= 2 && ($i ==0 || ${total{$key}}[$i-1] < 2)){
	    push(@start,$i);
	}
	elsif(${total{$key}}[$i] >= 2 && ($i == $seq_length-1 || ${total{$key}}[$i+1] < 2)){
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
