#!/usr/bin/perl -w
use strict;

my ($in,$goa)= @ARGV;
die "Error with arguments!\nusage: $0 <Input:GOterm-frequency.txt> <GOA database>\n" if (@ARGV<2);

open(IN,$in)||die("error\n");
open(GOA,$goa)||die("error\n");
#open(OUT,">$out")||die("Error\n");

my ($N,$n) = (68050,257);
# $N --> the number of background genes with GO annotation;                                                                       
# $n --> the number of target genes with GO annotation;

my %ontology = ();
while(<GOA>){
    chomp();
    my @arr = split(/\|/,$_);
    $ontology{$arr[0]} = $arr[2]."|".$arr[1];
}

print "GOterm\tBackground_ratio\tTarget_ratio\tP_value\tNameSpace\tDescription\n";
while(<IN>){
    chomp();
    my ($term,$m,$M) = split(/\s+/,$_);
    my $p_value = hypergeometric($N,$n,$M,$m);
    $p_value = sprintf("%0.8f",$p_value);
    $M = sprintf("%0.5f",$M/$N);
    $m = sprintf("%0.5f",$m/$n);
    if(exists($ontology{$term})){
	my ($NameSpace,$Description) = split(/\|/,$ontology{$term});
	print "$term\t$M\t$m\t$p_value\t$NameSpace\t$Description\n";
    }
    else{
	print "NO:$term\n";
    }
}

sub hypergeometric{
    my ($N,$n,$M,$m) = @_; 
    # $N --> the number of background genes with GO annotation;
    # $n --> the number of target genes with GO annotation;
    # $M --> the number of genes with a specific GO annotation, in the background;    
    # $m --> true frequency of a specific GO annotation in the target genes
    
    my $p_value = 1;
    for(my $i=0;$i<$m;$i++){
	my $result = sprintf("%0.32e",1);
	my ($number,$digit) = myTrans($result);

	my ($number_a,$digit_a) = combination($M,$i);
	my ($number_b,$digit_b) = combination($N-$M,$n-$i);
	my ($number_c,$digit_c) = combination($N,$n);

	$digit = $digit_a+$digit_b-$digit_c;
	$number = $number_a*$number_b/$number_c;
	$number = sprintf("%0.32e",$number);

	my ($number_this,$digit_this) = myTrans($number);
	$digit += $digit_this;
	$number = $number_this;

	my $pro=sprintf("%0.32e",$number*(10**$digit));
	$p_value -= $pro;
    }
    $p_value =  sprintf("%0.32e",$p_value);
    return $p_value;
}

sub combination{
    my ($N,$M) = @_; #N -- >all;  M --> select    
    my $result = sprintf("%0.32e",1);
    my ($number,$digit) = myTrans($result);

    for(my $i=$N-$M+1;$i<=$N;$i++){
	$i = sprintf("%0.32e",$i);
	my ($number_i,$digit_i) = myTrans($i);
	$number = sprintf("%0.32e",$number*$number_i);
	$digit += $digit_i;
	my ($number_j,$digit_j) = myTrans($number);
	$digit += $digit_j;
	$number = $number_j;
    }
    for(my $i=1;$i<=$M;$i++){
	$i = sprintf("%0.32e",$i);
        my ($number_i,$digit_i) = myTrans($i);
        $number = sprintf("%0.32e",$number/$number_i);
        $digit -= $digit_i;
        my ($number_j,$digit_j) = myTrans($number);
        $digit += $digit_j;
        $number = $number_j;
    }
    return ($number,$digit);
}

sub myTrans{
    my ($result) = @_;
    if($result =~ /([^\s]+)e([^\s]+)/){
	my ($number,$digit) = ($1,$2);
	return ($number,$digit);
    }
}

close IN;close GOA;
exit;
