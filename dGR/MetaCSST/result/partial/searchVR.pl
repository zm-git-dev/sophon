#!/usr/bin/perl -w
use strict;

#This script is used to search VRs according to the TRs and candidate sample reads

my ($tr,$srs,$out,$miss)= @ARGV;
die "Error with arguments!\nusage: $0 <TR.fa> <candidate sample reads> <OUT File> <maxNA mutation number>\n" if (@ARGV<4);

##default: $miss=3 (at most three T/C/G mutation)

open(OUT,">$out")||die("Error with writing to $out\n");
open(TR,$tr)||die("Error with opening $tr\n");

my $miss_half = int($miss/2);
my $TR = "";
while(<TR>){
    chomp();
    if($_ !~ />/){
	$TR = $_;	
	open(SRS,$srs)||die("Error with opening $srs\n");
	while(<SRS>){
	    chomp();
	    if($_ !~ />/){
		my $seq = $_;
		my $len = length($TR);
		my $quarter = int($len/4);
		my $middle = int($len/4)*2;
		my $quarter3 = int($len/4)*3;
		
		my $seq_left = substr($TR,0,$middle+1);
		my $seq_middle = substr($TR,$quarter,$quarter3-$quarter+1);
		my $seq_right = substr($TR,$middle,$len-$middle);
		
		my ($result,$index) = ("",0);
		($result,$index)=searchVR($TR,0,$len-1,$seq,$miss);
		if($index == 0){
		    ($result,$index)=searchVR($TR,$middle,$len-1,$seq,$miss);
		    if($index == 0){
			($result,$index)=searchVR($TR,$quarter,$quarter3,$seq,$miss);
			if($index == 0){
			    ($result,$index)=searchVR($TR,0,$middle,$seq,$miss);
			}
		    }
		}
		if($index == 1){
		    print OUT "$result";
		}
	    }
	    next;
	}
	close SRS;
    }
    next;
}
close OUT;
	
sub searchVR{
    my ($TR,$start,$end,$seq,$miss)=@_;
    my ($result,$index_all) = ("",0);
    
    if(length($seq) < length($TR)){
	return ($result,$index_all);
    }
    
    my $len=length($TR);
#search for positive string
    for(my $i=0;$i<=length($seq)-$len;$i++){

	my $index = 0;
	my $substr = substr($seq,$i,length($TR));
	
	my $error = 0;
	my $mut = 0;
	
	for(my $j=0;$j<$len;$j++){
	    my $char1 = substr($TR,$j,1);
	    my $char2 = substr($substr,$j,1);
	    if($char1 eq 'A' && $char1 ne $char2){
		$mut++;
	    }
	    elsif($char1 ne 'A' && $char1 ne $char2 ){
		$error += 1;
		if($error > $miss){
		    $index = 1;
		    last;
		}
	    }
	}
	
	if($index == 0){ ## a VR founded,extention
	    my ($left,$right)=(1,1);
	    for($left=1;$i-$left >= 0 && $start-$left >= 0;$left++){
		my $char1 = substr($TR,$start-$left,1); #TR
		my $char2 = substr($seq,$i-$left,1); #VR
		if($char1 eq 'A' && $char1 ne $char2){
		    $mut++;
		}
		elsif($char1 ne 'A' && $char1 ne $char2){
		    last;
		}
	    }
	    for($right=1;$i+$len-1+$right < length($seq) && $end+$right < length($seq);$right++){
		my $char1 = substr($TR,$end+$right,1);
		my $char2 = substr($seq,$i+$len-1+$right,1);
		if($char1 eq 'A' && $char1 ne $char2){
		    $mut++;
		}
		elsif($char1 ne 'A' && $char1 ne $char2){
		    last;
		}
	    }
	    $left -= 1;
	    $right -= 1;
	    
	    my ($a,$b,$c,$d)=($start-$left,$end+$right,$i-$left,$i+$len-1+$right);

	    my $TR_new = substr($TR,$a,$b-$a+1);
	    my $VR_new = substr($seq,$c,$d-$c+1);
	    
	    my $distance = abs($c-$a);
	    
	    $result .= "TR\t$mut\t$error\t$TR_new\n";
	    $result .= "VR\t$mut\t$error\t$VR_new\n";
	    $index_all += 1;
	}
    }
    
    #search for negative string
    my $seq1 = myReverse($seq);
    for(my $i=0;$i<=length($seq1)-length($TR);$i++){
	my $index = 0;
	my $substr = substr($seq1,$i,length($TR));
	
	my $error = 0;
	my $mut = 0;
	
	for(my $j=0;$j<$len;$j++){
	    my $char1 = substr($TR,$j,1);
	    my $char2 = substr($substr,$j,1);
	    
	    if($char1 eq 'A' && $char1 ne $char2 ){
		$mut++;
	    }
	    elsif($char1 ne 'A' && $char1 ne $char2 ){
		$error += 1;
		if($error > $miss){
		    $index = 1;
		    last;
		}
	    }
	}
	
	if($index == 0){ ## a VR founded,extention
	    my ($left,$right)=(1,1);
	    for($left=1;$i-$left >= 0 && $start-$left >= 0;$left++){
		my $char1 = substr($TR,$start-$left,1); #TR
		my $char2 = substr($seq1,$i-$left,1); #VR
		if($char1 eq 'A' && $char1 ne $char2 ){
		    $mut++;
		}
		elsif($char1 ne 'A' && $char1 ne $char2){
		    last;
		}
	    }
	    for($right=1;$i+$len-1+$right < length($seq) && $end+$right < length($seq);$right++){
		my $char1 = substr($TR,$end+$right,1);
		my $char2 = substr($seq1,$i+$len-1+$right,1);
		if($char1 eq 'A' && $char1 ne $char2 ){
		    $mut++;
		}
		elsif($char1 ne 'A' && $char1 ne $char2){
		    last;
		}
	    }
	    $left -= 1;
	    $right -= 1;
	    
	    my ($a,$b,$c,$d)=($start-$left,$end+$right,$i-$left,$i+$len-1+$right);
	    my $TR_new = substr($TR,$a,$b-$a+1);
	    my $VR_new = substr($seq1,$c,$d-$c+1);
	    
	    $result .= "TR\t$mut\t$error\t$TR_new\n";
            $result .= "VR\t$mut\t$error\t$VR_new\n";
            $index_all += 1;
	}
    }
    return ($result,$index_all);
}

sub numNA{ #count the number of nucleotide notA
    my ($seq) = @_;
    my $num = 0;
    for(my $i=0;$i<length($seq);$i++){
	my $char = substr($seq,$i,1);
	if($char ne 'A'){
	    $num++;
	}
    }
    return $num;
}

sub myReverse{
    my ($seq) = @_;
    my $new="";
    for(my $i=length($seq)-1;$i>=0;$i--){
	my $char = substr($seq,$i,1);
	if($char eq 'A' || $char eq 'a'){$new .= 'T';}
	elsif($char eq 'T' || $char eq 't'){$new .= 'A';}
	elsif($char eq 'C' || $char eq 'c'){$new .= 'G';}
	elsif($char eq 'G' || $char eq 'g'){$new .= 'C';}
	else{
	    $new .= $char;
	}
    }
    return $new;
}

exit;
