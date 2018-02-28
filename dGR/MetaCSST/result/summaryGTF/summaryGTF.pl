#!/usr/bin/perl -w
use strict;

my ($fa,$gtf,$summary)= @ARGV;
die "Error with arguments!\nusage: $0 <Genome in fasta format> <GTF File> <OUT File>\n" if (@ARGV<3);

open(FA,$fa)||die("error\n");
open(GTF,$gtf)||die("error\n"); 
open(OUT,">$summary")||die("error\n");

print OUT "DGR_ID\tSeq_length\tGC_percentage\tDGR_length\tTR_number\tPair_number\n";

my %LENGTH = ();
my %GC = ();
my $id="";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	my $len = length($_);
	$LENGTH{$id} = $len;
	my $num = 0;
	for(my $i=0;$i<$len;$i++){
	    my $base = substr($_,$i,1);
	    if($base eq 'G' || $base eq 'C'){
		$num += 1;
	    }
	}
	my $gc = sprintf("%0.1f",$num*100/$len);
	$gc .= "%";
	$GC{$id} = $gc;
	print "$id\t$GC{$id}\n";
    }
}

my %VR = ();
my ($len,$TR_num,$pair_num,$start,$end,$TR_start) = (0,0,0,10000000000000,0,0);
$id = "";
my %hash = ();
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[0] ne $id){
	if($id ne ""){
	    $len = $end-$start+1;
	    print OUT "$id\t$LENGTH{$id}\t$GC{$id}\t$len\t$TR_num\t$pair_num\n";
	    ($id,$len,$TR_num,$pair_num,$start,$end,$TR_start) = ($arr[0],0,0,0,10000000000000,0,0);
	}
	$id = $arr[0];
    }
    if($arr[1] eq "TR"){
	my $oriTR = $arr[0].$arr[2].$arr[3].$arr[4];
	if(not exists($hash{$oriTR})){
	    $hash{$oriTR} = 1;
	    $TR_num ++;
	}
	$TR_start = $arr[5];
	if($arr[5] < $start){$start = $arr[5]};
	if($arr[6] > $end){$end = $arr[6]};
    }
    elsif($arr[1] eq "VR"){
	my $copyVR = $arr[0].$arr[2].$arr[5].$arr[6];
	if(not exists($VR{$copyVR})){
	    $pair_num ++;
	    $VR{$copyVR} = 1;
	}
	my $dis = abs($arr[5] - $TR_start);
	if($arr[5] < $start){$start = $arr[5]};
        if($arr[6] > $end){$end = $arr[6]};
    }
    elsif($arr[1] eq "RT"){
	if($arr[3] < $start){$start = $arr[3]};
        if($arr[4] > $end){$end = $arr[4]};
    }
}

$len = $end-$start+1;
print OUT "$id\t$LENGTH{$id}\t$GC{$id}\t$len\t$TR_num\t$pair_num\n";

close GTF;close OUT;
exit;
