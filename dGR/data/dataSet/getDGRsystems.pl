#!/usr/bin/perl -w
use strict;

#This program is used to get the DGR systems according to the GTF annotation and DGR containing sequences

my ($fa,$gtf,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <DGR containing Fasta File> <Annotation GTF> <OUT>\n" if (@ARGV<3);

open(OUT,">$out")||die("Can't write to $out\n");
open(FA,$fa)||die("Can't open $fa$\n");
open(GTF,$gtf)||die("Can't open $gtf\n");

my %hash = ();
my $id = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$hash{$id} = $_;
    }
}

my ($start,$end) = (0,0);

$id = "";
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($_ =~ /RT/){  ###only one RT in the dataset
	if($id ne ""){
	    my $system = substr($hash{$id},$start,$end-$start+1);
	    print OUT ">$id\n$system\n";
	}
	$id = $arr[0];
	($start,$end) = ($arr[2],$arr[3]);
    }
    else{
	my ($start_new,$end_new) = ($arr[2],$arr[3]);
	if($start_new < $start){
	    $start = $start_new;
	}
	if($end_new > $end){
            $end = $end_new;
        }
    }
}

my $system = substr($hash{$id},$start,$end-$start+1);
print OUT ">$id\n$system\n";

close OUT;close FA;close GTF;
exit;
