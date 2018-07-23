#!/usr/bin/perl -w
use strict;

my ($hit,$info,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <screenHGT-len0.4.out> <species info with name and assembly id> <OUT File>" if (@ARGV<3);

open(HIT,$hit)||die("error with opening $hit\n");
open(INFO,$info)||die("error with opening $info\n");
open(OUT,">$out")||die("error\n");

my %hash = ();
while(<INFO>){
    chomp();
    my @arr = split(/\s+/,$_);
    $hash{$arr[1]} = $arr[0];
    next;
}

while(<HIT>){
    chomp();
    my @arr = split(/\s+/,$_);
    if(@arr == 4){
	print OUT "$_";
    }
    else{
	my @species = split(/,/,$arr[4]);
	for(my $i=0;$i<@species;$i++){
	    my $name = $species[$i]."_genomic.fna.gz";
	    if(exists($hash{$name})){
		$species[$i] = $hash{$name};
	    }
	    else{
		die("error with species name\n$name\n");
	    }
	}
	print OUT "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t";
	for(my $i=0;$i<@species;$i++){
	    if($i == @species-1){
		print OUT "$species[$i]\n";
	    }
	    else{
		print OUT "$species[$i],";
	    }
	}
    }
}

close HIT;close INFO;close OUT;
exit;
