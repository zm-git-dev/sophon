#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die "Error with arguments!\nusage: $0 <Result files by DiGReF>\n" if (@ARGV<1);
open(OUT,">DGR_summary.txt")||die("can't write to DGR_summary.txt\n");

my @length_tr=();my @length_vr=();my @length_rt=();
my @length_dgr=();
my @gap=();
my ($mut_A,$mut_T,$mut_C,$mut_G)=(0,0,0,0);

foreach my $file(@files){
    open(FILE,$file)||die("can't open $file\n");
    my @line=<FILE>;
    my @TR=();my @VR=();
    my @start_TR=();my @start_VR=();
    if(@line > 9){
	my ($start,$end)=(0,0);
	if($line[0] =~ /(\d+)\.\.(\d+)/){
	    ($start,$end)=($1,$2);
	    push(@length_rt,length($line[1]));
	}
	for(my $i=0;$i<@line;$i++){
	    if($line[$i] =~ />TR\d+\/(\d+)--(\d+)\//){
		push(@length_tr,$2-$1+1);
		my @arr = split(/\s+/,$line[$i+1]);
		push(@TR,$arr[0]);
		push(@start_TR,$1);
		if($1 < $start){$start = $1;}
		if($2 > $end){$end = $2;}
	    }
	    elsif($line[$i] =~ />VR\d+\/(\d+)--(\d+)\//){
                push(@length_vr,$2-$1+1);
                my @arr = split(/\s+/,$line[$i+1]);
                push(@VR,$arr[0]);
		push(@start_VR,$1);
                if($1 < $start){$start = $1;}
                if($2 > $end){$end = $2;}
            }
	}
	for(my $i=0;$i<@start_TR;$i++){
	    push(@gap,abs($start_TR[$i]-$start_VR[$i]));
	}
	for(my $i=0;$i<@TR;$i++){
	    for(my $j=0;$j<length($TR[$i]);$j++){
		my $chr1 = substr($TR[$i],$j,1);
		if($chr1 eq 'A'){
		    my $chr2 = substr($VR[$i],$j,1);
		    if($chr2 eq 'A'){
			$mut_A += 1;
		    }
		    elsif($chr2 eq 'T'){
                        $mut_T += 1;
                    }
		    elsif($chr2 eq 'C'){
                        $mut_C += 1;
                    }
		    elsif($chr2 eq 'G'){
                        $mut_G += 1;
                    }
		}
	    }
	}
	push(@length_dgr,$end-$start+1);
    }
    close FILE;
}

my ($max,$avg,$min)=avg(@length_dgr);
print OUT "DGR length:\tMax:$max\tAverage:$avg\tMin:$min\n";
for(my $i=0;$i<@length_dgr;$i++){
    if($i != @length_dgr-1){
        print OUT "$length_dgr[$i]\t";
    }
    else{
        print OUT "$length_dgr[$i]\n\n";
    }
}
($max,$avg,$min)=avg(@length_rt);
print OUT "RT length:\tMax:$max\tAverage:$avg\tMin:$min\n";
for(my $i=0;$i<@length_rt;$i++){
    if($i != @length_rt-1){
	print OUT "$length_rt[$i]\t";
    }
    else{
	print OUT "$length_rt[$i]\n\n";
    }
}
($max,$avg,$min)=avg(@length_tr);
print OUT "TR length:\tMax:$max\tAverage:$avg\tMin:$min\n";
for(my $i=0;$i<@length_tr;$i++){
    if($i != @length_tr-1){
        print OUT "$length_tr[$i]\t";
    }
    else{
        print OUT "$length_tr[$i]\n\n";
    }
}

($max,$avg,$min)=avg(@gap);
print OUT "Gap between VR and TR:\tMax:$max\tAverage:$avg\tMin:$min\n";
for(my $i=0;$i<@gap;$i++){
    if($i != @gap-1){
        print OUT "$gap[$i]\t";
    }
    else{
        print OUT "$gap[$i]\n\n";
    }
}


my $mut_total=$mut_A+$mut_T+$mut_C+$mut_G;
print OUT "Nucleotide mutation:\n";
$mut_A = sprintf("%0.2f",$mut_A/$mut_total);$mut_T = sprintf("%0.2f",$mut_T/$mut_total);$mut_C = sprintf("%0.2f",$mut_C/$mut_total);$mut_G = sprintf("%0.2f",$mut_G/$mut_total);
print OUT "A->A:$mut_A\tA->T:$mut_T\tA->C:$mut_C\tA->G:$mut_G\t";
close OUT;

sub avg{
    my (@data)=@_;
    my ($max,$avg,$sum,$min)=(0,0,0,100000000);
    foreach my $i(@data){
	if($i > $max){$max = $i;}
	if($i < $min){$min = $i;}
	$sum += $i;
    }
    $avg = int($sum/@data);
    return ($max,$avg,$min);
}
exit;


