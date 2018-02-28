#!/usr/bin/perl -w
use strict;

my ($gtf,$dir)= @ARGV;
die "Error with arguments!\nusage: $0 <HMASM.gtf> <OUT Directory>\n" if (@ARGV<2);

open(GTF,$gtf)||die("error\n");

my $ID = "";
my $index = 0;

my $num = 1;
while(<GTF>){
    chomp();
    if($_ =~ /TR/){
	my @arr=split(/\s+/,$_);
	$ID = $arr[0];
	my $seq = $arr[6];
	if($index == 0){
	    open(OUT,">$dir/$ID.TR.fa")||die("error\n");
	    $index = 1;
	}
	my $id = ">".$ID."_TR".$num;
	print OUT "$id\n$seq\n";
	$num += 1;
    }
    elsif($_ =~ /DGR/){
	close OUT;
	$index = 0;
	$num = 1;
    }
    next
}
