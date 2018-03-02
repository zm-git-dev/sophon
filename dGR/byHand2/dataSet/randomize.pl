#!/usr/bin/perl -w
use strict;

#This script is used to randomize the sequences order in the merged.gtf

my ($gtf,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Merged.gtf> <OUT File>\n" if (@ARGV<2);

open(GTF,$gtf)||die("error with opening $gtf\n");
open(OUT,">$out")||die("error with writing to $out\n");

my @data = ();
my $dgr_number = -1;
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[1] eq "RT"){
        $dgr_number +=1;
        $data[$dgr_number] = $_."\n";
    }
    elsif($arr[1] eq "TR"){
        $data[$dgr_number] .= $_."\n";
    }
    elsif($arr[1] eq "VR"){
        $data[$dgr_number] .= $_."\n";
    }
    next;
}

our @order = ();
my @number = ();
for(my $i=0;$i<=$dgr_number;$i++){
    push(@number,$i);
}
randomSelect(@number);
foreach my $i(@order){
    print OUT "$data[$i]";
}

sub randomSelect{
    my (@arr) = @_;
    my $size = @arr;
    
    my @left = ();
    srand();
    my $rand_int = int(rand($size));
    
    push(@order,$arr[$rand_int]);
    
    my $select = $arr[$rand_int];
    for(my $i=0;$i<$rand_int;$i++){
	push(@left,$arr[$i]);
    }
    for(my $i=$rand_int+1;$i<$size;$i++){
	push(@left,$arr[$i]);
    }
    if(@left >= 1){
	randomSelect(@left);
    }
}

close GTF;close OUT;
exit;
