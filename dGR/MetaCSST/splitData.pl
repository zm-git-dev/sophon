#!/usr/bin/perl -w
use strict;

#This script is used to split the total data to a training set and a test set according to the merged DGR dataset from DiGReF & DGRscan,for K-fold Cross Validation, split K groups

my ($gtf,$fa,$k)= @ARGV;
die "Error with arguments!\nusage: $0 <Merged.gtf DataSet> <Merged.DGR.fa> K value in cross validation>\n" if (@ARGV<3);

open(GTF,$gtf)||die("error with opening $gtf\n");
open(FA,$fa)||die("error with opening $fa\n");

my @data = ();
#@data structure:[id,RT,TR,VR]

my $dgr_number = -1;
my $dgr_id = "";
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[1] eq "RT"){
	$dgr_number +=1;
	$dgr_id = $arr[0];
	$data[$dgr_number][0] = $dgr_id;
	$data[$dgr_number][1] .= ">$arr[0]\n$arr[5]\n";
    }
    elsif($arr[1] eq "TR"){
	$data[$dgr_number][2] .= ">$arr[0]\n$arr[5]\n";
    }
    elsif($arr[1] eq "VR"){
	$data[$dgr_number][3] .= ">$arr[0]\n$arr[5]\n";
    }
    next;
}

my %DGR = ();
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$dgr_id = $1;
    }
    else{
	$DGR{$dgr_id} = $_;
    }
}

my $test_number = int(($dgr_number+1)/$k) + 1;

for(my $i=1;$i<=$k;$i++){
    print "$i\n";
    my %test = ();

    my $start = $test_number*($i-1);
    my $end = $test_number*$i;
    
    for(my $j=$start;$j<$end && $j<= $dgr_number;$j++){
	$test{$j} = 1;
    }
    
    my $dir = "group_".$i;
    system("mkdir $dir");
    my ($train,$test) = ($dir."/train",$dir."/test");
    system("mkdir $train");
    system("mkdir $test");

    open(TRAIN_TR,">$train/TR.fa")||die("error with writting to $train/TR.fa\n");
    open(TRAIN_VR,">$train/VR.fa")||die("error with writting to $train/VR.fa\n");
    open(TRAIN_RT,">$train/RT.fa")||die("error with writting to $train/RT.fa\n");
    open(TRAIN_DGR,">$train/DGR.fa")||die("error with writting to $train/DGR.fa\n");
    open(TEST_TR,">$test/TR.fa")||die("error with writting to $test/TR.fa\n");
    open(TEST_VR,">$test/VR.fa")||die("error with writting to $test/VR.fa\n");
    open(TEST_RT,">$test/RT.fa")||die("error with writting to $test/RT.fa\n");
    open(TEST_DGR,">$test/DGR.fa")||die("error with writting to $test/DGR.fa\n");

    for(my $j=0;$j<=$dgr_number;$j++){
	if(exists($test{$j})){
	    my $jd_tmp = $data[$j][0];
	    print TEST_DGR ">$jd_tmp\n$DGR{$jd_tmp}\n";
	    print TEST_RT "$data[$j][1]";
	    print TEST_TR "$data[$j][2]";
	    print TEST_VR "$data[$j][3]";
	}
	else{
	    my $jd_tmp = $data[$j][0];
	    print TRAIN_DGR ">$jd_tmp\n$DGR{$jd_tmp}\n";
	    print TRAIN_RT "$data[$j][1]";
	    print TRAIN_TR "$data[$j][2]";
	    print TRAIN_VR "$data[$j][3]";
	}
    }
    close TRAIN_TR;close TRAIN_VR;close TRAIN_RT;close TRAIN_DGR;
    close TEST_TR;close TEST_VR;close TEST_RT;close TEST_DGR;
}

system("sh mkdir.sh $k");

close GTF;close FA;
exit;
