#!/usr/bin/perl -w
use strict;

my ($info,$dir)= @ARGV;
die "Error with arguments!\nusage: $0 <sample_incomplete.info> <OUT Directory>\n" if (@ARGV<2);

open(INFO,$info)||die("error\n");

while(<INFO>){
    chomp();
    if($_ !~ /ID/){
	my @arr = split(/\s+/,$_);
	my $TR = $arr[0];
	my $sample = $arr[1];
	my $out = $dir."/".$sample."-".$TR.".m8";
	print "sbatch blastn.slurm $TR $sample $out\n";
    }
    next
}

close INFO;
