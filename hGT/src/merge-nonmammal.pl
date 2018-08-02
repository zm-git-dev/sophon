#!/usr/bin/perl -w
use strict;

#get regions conserved in non-mammal genomes, overlapped sequences >= 500bp && at least two non-mammal species sharing this region

my ($fa,$len_cuttof,$cov_cuttof,$out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Reference fasta file> <Length cuttof> <Cov species cuttof> <OUT file> <Non-mammal bed files (sorted, merged)> \n" if (@ARGV<5);

open(FA,$fa)||die("error with opening $fa\n");
open(OUT,">$out")||die("error with writing to $out\n");

my $seq_name = "";
my %coverage = ();  ## coverage depth for this sequence
my %len = ();  ## length
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$seq_name = $1;
    }
    else{
	my $len_this = length($_);
	my @cov = ();
        for(my $i=0;$i<$len_this;$i++){
            push(@cov,0);
        }
	$len{$seq_name} =  $len_this;
        $coverage{$seq_name} = \@cov;
    }
    
}

foreach my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    print "$file\n";
    while(<FILE>){
	my @arr = split(/\s+/,$_);
	my ($seq,$start,$end) = ($arr[0],$arr[1],$arr[2]);
	if(exists($coverage{$seq})){
	    for(my $i=$start-1;$i<=$end-1;$i++){
		${coverage{$seq}}[$i] += 1;
	    }
	}
    }
    close FILE;
}

foreach my $key(keys %coverage){
    my @start = ();
    my @end = ();
    my $seq_length = $len{$key};
    for(my $i=0;$i<$seq_length;$i++){
	if(${coverage{$key}}[$i] >= $cov_cuttof && ($i ==0 || ${coverage{$key}}[$i-1] < $cov_cuttof)){
	    if(${coverage{$key}}[$i+1] >= $cov_cuttof){
		push(@start,$i+1);  ## start position, count from 1
	    }
	}
	elsif(${coverage{$key}}[$i] >= $cov_cuttof && ($i == $seq_length-1 || ${coverage{$key}}[$i+1] < $cov_cuttof)){
	    push(@end,$i+1);  ##end position, count from 1
	}
    }
    
    for(my $i=0;$i<@start;$i++){
	if($end[$i]-$start[$i] >= $len_cuttof-1){
	    print OUT "$key\t$start[$i]\t$end[$i]\n";
	}
    }
}

exit;
