#!/usr/bin/perl -w
use strict;

my ($file,$fa,$out) = @ARGV;
die("usage: $0 <DRGscan Out Summary File> <FASTA File> <OUT File>\n") if(@ARGV<3);
open(OUT,">$out")||die("error with writing to $out\n");
open(FILE,$file)||die("error with opening $file\n");


my %hash = ();

open(FA,$fa)||die("error with opeing $fa\n");
my ($seq_id,$seq_seq) = ("","");
while(<FA>){
    chomp();
            if($_ =~ />(.+)/){
                $seq_id = $1;
            }
    else{
	$hash{$seq_id} = $_;
    }
}
close FA;

while(<FILE>){
    chomp();
    if($_ =~ /Putative RT:/){
	my @arr = split(/\s+/,$_);
	my ($id,$start,$end,$sequence,$string,$len) = ($arr[2],-1,-1,"","+",0);
	if($arr[8] <= $arr[9]){
	    ($start,$end) = ($arr[8],$arr[9]);
	}
	else{
	    ($start,$end,$string) = ($arr[9],$arr[8],"-");
	}
	$len = $end-$start+1;
	$sequence = substr($hash{$id},$start-1,$end-$start);
	my $new_seq = rev($sequence,$string);
	print OUT "$id\tRT\t$start\t$end\t$len\t$new_seq\n";
    }
}

sub rev{
    my ($seq,$string) = @_;
    if($string eq "+"){
	return $seq;
    }
    else{
	my $new = "";
	for(my $i=length($seq)-1;$i >= 0;$i--){
	    my $char = substr($seq,$i,1);
	    if($char eq 'A' || $char eq 'a'){
		$new .= 'T';
	    }
	    elsif($char eq 'T' || $char eq 't'){
		$new .= 'A';
	    }
	    elsif($char eq 'C' || $char eq 'c'){
		$new .= 'G';
	    }
	    elsif($char eq 'G' || $char eq 'g'){
		$new .= 'C';
	    }
	    else{
		$new .= $char;
	    }
	}
	return $new;
    }
}
close FILE;close OUT;
exit;
