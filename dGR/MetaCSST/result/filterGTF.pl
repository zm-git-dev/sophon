#!/usr/bin/perl -w
use strict;

#This script is used to check the rebuild GTF File, whether the mutA number and mutNA number are right. In addition, the homology cuttoff and a length threshold are set

my ($gtf,$homo,$out)= @ARGV;
#my ($gtf,$homo,$len,$out)= @ARGV;

#$homo=0.62;

die "Error with arguments!\nusage: $0 <GTF File> <Homology threshold> <OUT File>\n" if (@ARGV<3);
#die "Error with arguments!\nusage: $0 <GTF File> <Homology threshold> <Length cuttof> <OUT File>\n" if (@ARGV<4);
open(GTF,$gtf)||die("error\n");
open(OUT,">$out")||die("error\n");

my ($id,$tmp,$TR) = ("","","");
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[0] ne $id){
	if($id ne ""){
	    if($tmp =~ /\sRT\s/ && $tmp =~ /\sVR\s/){
		print OUT "$tmp";
	    }
	}
	$id = $arr[0];
	($tmp,$TR) = ("","");
    }
    if($arr[1] eq "RT"){$tmp .= $_."\n";}
    elsif($arr[1] eq "TR"){$TR = $_;}
    elsif($arr[1] eq "VR"){
	my @data_TR = split(/\s+/,$TR);
	if(reCheck($data_TR[9],$arr[9],$arr[7],$arr[8],$homo) == 0){
	#if(reCheck($data_TR[9],$arr[9],$arr[7],$arr[8],$homo,$len) == 0){
	    $tmp .= $TR."\n".$_."\n";
	}
    }
}

if($tmp =~ /\sRT\s/ && $tmp =~ /\sVR\s/){
    print OUT "$tmp";
}

sub reCheck{    
    my ($TR,$VR,$mutA,$mutNA,$homo) = @_;
    #my ($TR,$VR,$mutA,$mutNA,$homo,$len) = @_;
    my ($mut,$err) = (0,0);
    my $same = 0;
    for(my $i=0;$i<length($TR);$i++){
	my $char1 = substr($TR,$i,1);
	my $char2 = substr($VR,$i,1);
	if($char1 ne $char2){
	    if($char1 eq 'A'){$mut ++;}
	    else{$err ++;}
	}
	else{$same ++;}
    }
    my $homo_this = sprintf("%0.2f",$same/length($TR));
    if($mut != $mutA || $err != $mutNA){
	return -1;
    }
    elsif($homo_this < $homo){
    #elsif($homo_this < $homo || length($TR) < $len){
	return -1;
    }
    else{
	return 0;
    }
}

exit;
