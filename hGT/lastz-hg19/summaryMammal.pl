#!/usr/bin/perl -w
use strict;

#get regions conserved in non-mammal genomes, overlapped sequences >= 500bp && at least two non-mammal species sharing this region

my ($index,$out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Nonmammal Merged Bed File> <OUT File> <files of mammal coverage> \n" if (@ARGV<3);

open(INDEX,$index)||die("error with opening $index\n");
open(OUT,">$out")||die("error eith writing to $out\n");

my %hash = ();

while(<INDEX>){
    chomp();
    my @data = split(/\s+/,$_);
    my $key = "$data[0]\t$data[1]\t$data[2]";
    $hash{$key} = 0;
}

foreach my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    while(<FILE>){
	chomp();
	my @data = split(/\s+/,$_);
	my $key = "$data[0]\t$data[1]\t$data[2]";
	$hash{$key} += $data[3];
    }
    close FILE;
}
foreach my $key(keys %hash){
    print OUT "$key\t$hash{$key}\n";
}
close OUT;
exit;
