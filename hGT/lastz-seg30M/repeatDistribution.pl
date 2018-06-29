#!/usr/bin/perl -w
use strict;

my ($hit,$repeat,$out)=@ARGV;
die "Error with arguments!\nusage: $0 <summaryHit-iden90.txt> <474hgt2repeat.txt> <OUT File>" if (@ARGV<3);

open(HIT,$hit)||die("error with opening $hit\n");
open(OUT,">$out")||die("error\n");

print OUT "region\thit\trepeat\tcov_length\tcov_percent\n";
while(<HIT>){
    chomp();
    if($_ !~ /id/){
	my @arr = split(/\s+/,$_);
	my ($region,$hit_num) = ($arr[0],$arr[1]);
	my %hash = ();
	open(REPEAT,$repeat)||die("error with opening $repeat\n");
	while(<REPEAT>){
	    chomp();
	    my @data = split(/\s+/,$_);
	    my ($chr,$start,$end,$start2,$end2,$type) = ($data[0],$data[1],$data[2],$data[5],$data[6],$data[7]);
	    my $region2 = $chr."-".$start."-".$end;
	    if($region eq $region2){
		my ($start_overlap,$end_overlap) = ($start,$end);
		if($start2>$start){$start_overlap = $start2;}
		if($end2<$end){$end_overlap = $end2;}
		my $len = $end_overlap-$start_overlap+1;
		if(not exists($hash{$type})){
		    $hash{$type} = $len;
		}
		else{
		    $hash{$type} += $len;
		}
	    }
	}
	close REPEAT;
	my @site = split(/-/,$region);
	my $len_this = $site[2]-$site[1]+1;
	my $cov_total = 0;
	foreach my $key(keys %hash){
	    my $tmp = sprintf("%0.3f",$hash{$key}/$len_this);
	    $cov_total += $hash{$key};
	    print OUT "$region\t$hit_num\t$key\t$hash{$key}\t$tmp\n";
	}
	my $tmp = sprintf("%0.3f",$cov_total/$len_this);
	print OUT "$region\t$hit_num\tALL\t$cov_total\t$tmp\n";
    }
}

close HIT;close REPEAT;close OUT;
exit;
