#!/usr/bin/perl -w
use strict;

#This script is used to split the total data to a training set and a test set according to the merged DGR dataset from DiGReF & DGRscan,for K-fold Cross Validation

my ($gtf,$fa,$train,$test,$k)= @ARGV;
die "Error with arguments!\nusage: $0 <Merged.gtf DataSet> <Merged.DGR.fa> <Training Directory> <Test Directory> <K value in cross validation>\n" if (@ARGV<5);

open(GTF,$gtf)||die("error with opening $gtf\n");
open(FA,$fa)||die("error with opening $fa\n");
open(TRAIN_TR,">$train/TR.fa")||die("error with writting to $train/TR.fa\n");
open(TRAIN_VR,">$train/VR.fa")||die("error with writting to $train/VR.fa\n");
open(TRAIN_RT,">$train/RT.fa")||die("error with writting to $train/RT.fa\n");
open(TRAIN_DGR,">$train/DGR.fa")||die("error with writting to $train/DGR.fa\n");

open(TEST_TR,">$test/TR.fa")||die("error with writting to $test/TR.fa\n");
open(TEST_VR,">$test/VR.fa")||die("error with writting to $test/VR.fa\n");
open(TEST_RT,">$test/RT.fa")||die("error with writting to $test/RT.fa\n");
open(TEST_DGR,">$test/DGR.fa")||die("error with writting to $test/DGR.fa\n");

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

my @id_list = ();
for(my $i=0;$i<=$dgr_number;$i++){
    push(@id_list,$i);
}

my $test_number = int(($dgr_number+1)/$k);
my %test = ();

for(my $i=0;$i<=$test_number;){
    my $ID = randomSample(@id_list,%test);
    if(not exists($test{$ID})){
        $test{$ID} = 1;
        $i++;
    }
}

for(my $i=0;$i<=$dgr_number;$i++){
    if(exists($test{$i})){
	my $id_tmp = $data[$i][0];
	print TEST_DGR ">$id_tmp\n$DGR{$id_tmp}\n";
	print TEST_RT "$data[$i][1]";
	print TEST_TR "$data[$i][2]";
	print TEST_VR "$data[$i][3]";
    }
    else{
	my $id_tmp = $data[$i][0];
        print TRAIN_DGR ">$id_tmp\n$DGR{$id_tmp}\n";
	print TRAIN_RT "$data[$i][1]";
        print TRAIN_TR "$data[$i][2]";
	print TRAIN_VR "$data[$i][3]";
    }
}

sub randomSample{
    my (@id_list,%choose) = @_;
    my @id = ();
    foreach my $key(@id_list){
        if(not exists($choose{$key})){
            push(@id,$key);
        }
    }

    my $size = @id;
    my $int=int(rand($size));
    return $id[$int];
}

close GTF;close FA;
exit;
