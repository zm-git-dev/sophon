#!/usr/bin/perl -w
use strict;

## compare the kmer frequencies of hgt and seg, with hg19 as background

my ($hgt,$seg,$hg19,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <HGT-kmer.txt> <SEG-kmer.txt> <hg19-kmer.txt> <OUT file>\n" if (@ARGV<4);

open(HG19,$hg19)||die("error\n");
open(SEG,$seg)||die("error\n");
open(HGT,$hgt)||die("error\n");
open(OUT,">$out")||die("error\n");

my @genome = ();
while(<HG19>){
    chomp();
    if($_ =~ /hg19/){
	@genome = split(/\s+/,$_);
	last;
    }
}

print OUT "region\tdistance\ttype\n";
while(<HGT>){
    chomp();
    my @data = split(/\s+/,$_);
    my $distance = 0;
    my $size = @genome;
    for(my $i=1;$i<$size;$i++){
	$distance += ($data[$i]-$genome[$i])**2;
    }
    print OUT "$data[0]\t$distance\tHGT\n";
}

while(<SEG>){
    chomp();
    my @data = split(/\s+/,$_);
    my $distance = 0;
    my $size = @genome;
    for(my $i=1;$i<$size;$i++){
        $distance += ($data[$i]-$genome[$i])**2;
    }
    print OUT "$data[0]\t$distance\tSEG\n";
}

close HG19;close HGT;close SEG;close OUT;
exit;
