#!/usr/bin/perl -w
use strict;

#get regions conserved in non-mammal genomes, overlapped sequences >= 1kbp && at least two non-mammal species sharing this region

my ($index,$chr,$out,$len_cuttof,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Reference chr_len.txt> <chromosome> <OUT File> <length cuttof> <non-mammal bed files> \n" if (@ARGV<4);

open(INDEX,$index)||die("error with opening $index\n");
open(OUT,">$out")||die("error eith writing to $out\n");

my %hash = ();
print "build reference index...\n";

my $chr_length = 0;
while(<INDEX>){
    chomp();
    my ($seq_name,$seq_length) = split(/\s+/,$_);
    if($seq_name eq $chr){
	$chr_length = $seq_length;
	print "$chr length: $chr_length\n";
	my @cov = ();
	for(my $i=0;$i<$seq_length;$i++){
	    push(@cov,0);
	}
	$hash{$chr} = \@cov;
    }
}
print "build reference index complete!\n";

foreach my $file(@files){
    print "mapping $file...\n";
    open(FILE,$file)||die("error with opening $file\n");
    while(<FILE>){
	chomp();
	my @arr = split(/\s+/,$_);
	my ($seq,$start,$end) = ($arr[0],$arr[1],$arr[2]);
	if($seq eq $chr){
	    for(my $i=$start-1;$i<=$end-1;$i++){
		${hash{$seq}}[$i] += 1;
	    }
	}
    }
    close FILE;
}
print "construct conserved regions...\n";

#foreach my $key(keys %hash){
my @start = ();
my @end = ();
for(my $i=0;$i<$chr_length;$i++){
    my $index = ${hash{$chr}}[$i];
    if(${hash{$chr}}[$i] >= 2 && ($i ==0 || ${hash{$chr}}[$i-1] < 2)){
	if(${hash{$chr}}[$i+1] >= 2){
	    push(@start,$i);
	}
    }
    elsif(${hash{$chr}}[$i] >= 2 && ($i == $chr_length-1 || ${hash{$chr}}[$i+1] < 2)){
	push(@end,$i);
    }
}

for(my $i=0;$i<@start;$i++){
    if($end[$i]-$start[$i] >= $len_cuttof-1){  ##len >= 1kbp 
	print OUT "$chr\t$start[$i]\t$end[$i]\n";
    }
}

#}
print "construct conserved regions complete!\n";

close OUT;
exit;
