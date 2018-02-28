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
            if($_ =~ />([^\s]+)/){
                $seq_id = $1;
            }
    else{
	$hash{$seq_id} = $_;
    }
}
close FA;


my %choose = ();
while(<FILE>){
    chomp();
    if($_ =~ /Template:/){
	my @arr = split(/\s+/,$_);
	my $id = $arr[1];
	print "$id\n";
	my $dgr = $hash{$id};
	if(not exists($choose{$id})){
	    print OUT ">$id\n$dgr\n";
	    $choose{$id} = 1;
	}
    }
}

close FILE;close OUT;
exit;
