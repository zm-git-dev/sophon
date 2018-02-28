#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die "Error with arguments!\nusage: $0 <Result files by DiGReF>\n" if (@ARGV<1);
open(OUT,">summary.txt")||die("can't write to DGR_summary.txt\n");

my (@start,@end) = ((),());
my (@trans_TR,@trans_VR,@trans_RT) = ((),(),());
my (@len_TR,@len_VR,@len_RT)=((),(),());
my (@gap_TR_TR,@gap_TR_VR,@gap_TR_RT,@gap_VR_TR,@gap_VR_VR,@gap_VR_RT,@gap_RT_TR,@gap_RT_VR,@gap_RT_RT);
my ($sum_TR,$sum_VR,$sum_RT)=(0,0,0);

foreach my $file(@files){
    open(FILE,$file)||die("can't open $file\n");
    my @line=<FILE>;
    my (@pos,@len,@type) = ((),(),());
    my $index = 0;
    if(@line > 9){
	my $DGR = $line[3];
	my $RT = $line[1];
	push(@pos,strstr($DGR,$RT));push(@len,length($RT));push(@type,"RT");
	
	for(my $i=0;$i<@line;$i++){
	    if($line[$i] =~ /no TR and VR/){
		$index = 1;
		last;
	    }
	    elsif($line[$i] =~ />TR\d+\/(\d+)--(\d+)\//){
		my @data = split(/\s+/,$line[$i+1]);
		my $TR = $data[0];
		push(@pos,strstr($DGR,$TR));push(@len,length($TR));push(@type,"TR");
	    }
	    elsif($line[$i] =~ />VR\d+\/(\d+)--(\d+)\//){
                my @data = split(/\s+/,$line[$i+1]);
                my $VR = $data[0];
                push(@pos,strstr($DGR,$VR));push(@len,length($VR));push(@type,"VR");
            }
	}
	
	if($index == 0){
	    for(my $i=0;$i<@len-1;$i++){ #sort
		for(my $j=$i+1;$j<@len;$j++){
		    if($pos[$i] > $pos[$j]){
			my ($a,$b,$c) = ($pos[$j],$len[$j],$type[$j]);
			($pos[$j],$len[$j],$type[$j]) = ($pos[$i],$len[$i],$type[$i]);
			($pos[$i],$len[$i],$type[$i]) = ($a,$b,$c);
		    }
		}
	    }
	    for(my $i=0;$i<@len;$i++){
		if($i == 0){push(@start,$type[$i]);}
		elsif($i == @len-1){
		    push(@end,$type[$i]);
		    if($type[$i] eq "TR"){
			$sum_TR +=1;
		    }
		    elsif($type[$i] eq "VR"){
                        $sum_VR +=1;
                    }
		    elsif($type[$i] eq "RT"){
                        $sum_RT +=1;
                    }
		}
		
		if($i < @len-1){
		    if($type[$i] eq "TR"){push(@trans_TR,$type[$i+1]);}
		    elsif($type[$i] eq "VR"){push(@trans_VR,$type[$i+1]);}
		    elsif($type[$i] eq "RT"){push(@trans_RT,$type[$i+1]);}
		}
	    }
	    for(my $i=0;$i<@len;$i++){
		if($type[$i] eq "TR"){push(@len_TR,$len[$i]);}
		elsif($type[$i] eq "VR"){push(@len_VR,$len[$i]);}
		elsif($type[$i] eq "RT"){push(@len_RT,$len[$i]);}
	    }

	    for(my $i=0;$i<@len-1;$i++){
		if($pos[$i+1]-$pos[$i] >= $len[$i]){
		    if($type[$i] eq "TR"){
			if($type[$i+1] eq "TR"){push(@gap_TR_TR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "VR"){push(@gap_TR_VR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "RT"){push(@gap_TR_RT,$pos[$i+1]-$pos[$i]);}
		    }
		    elsif($type[$i] eq "VR"){
			if($type[$i+1] eq "TR"){push(@gap_VR_TR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "VR"){push(@gap_VR_VR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "RT"){push(@gap_VR_RT,$pos[$i+1]-$pos[$i]);}
		    }
		    elsif($type[$i] eq "RT"){
			if($type[$i+1] eq "TR"){push(@gap_RT_TR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "VR"){push(@gap_RT_VR,$pos[$i+1]-$pos[$i]);}
			elsif($type[$i+1] eq "RT"){push(@gap_RT_RT,$pos[$i+1]-$pos[$i]);}
		    }
		}
	    }
	}
    }
    close FILE;
}

$sum_TR += @trans_TR;
$sum_VR += @trans_VR;
$sum_RT += @trans_RT;

my ($min_len_TR,$avg_len_TR,$max_len_TR) = count(@len_TR);
my ($min_len_VR,$avg_len_VR,$max_len_VR) = count(@len_VR);
my ($min_len_RT,$avg_len_RT,$max_len_RT) = count(@len_RT);

my ($min_gap_TR_TR,$avg_gap_TR_TR,$max_gap_TR_TR) = count(@gap_TR_TR);
my ($min_gap_TR_VR,$avg_gap_TR_VR,$max_gap_TR_VR) = count(@gap_TR_VR);
my ($min_gap_TR_RT,$avg_gap_TR_RT,$max_gap_TR_RT) = count(@gap_TR_RT);

my ($min_gap_VR_TR,$avg_gap_VR_TR,$max_gap_VR_TR) = count(@gap_VR_TR);
my ($min_gap_VR_VR,$avg_gap_VR_VR,$max_gap_VR_VR) = count(@gap_VR_VR);
my ($min_gap_VR_RT,$avg_gap_VR_RT,$max_gap_VR_RT) = count(@gap_VR_RT);

my ($min_gap_RT_TR,$avg_gap_RT_TR,$max_gap_RT_TR) = count(@gap_RT_TR);
my ($min_gap_RT_VR,$avg_gap_RT_VR,$max_gap_RT_VR) = count(@gap_RT_VR);
my ($min_gap_RT_RT,$avg_gap_RT_RT,$max_gap_RT_RT) = count(@gap_RT_RT);

my ($start_TR,$start_VR,$start_RT,$end_TR,$end_VR,$end_RT) = (0,0,0,0,0,0);
for(my $i=0;$i<@start;$i++){
    if($start[$i] eq "TR"){$start_TR++;}
    elsif($start[$i] eq "VR"){$start_VR++;}
    elsif($start[$i] eq "RT"){$start_RT++;}
    
    if($end[$i] eq "TR"){$end_TR++;}
    elsif($end[$i] eq "VR"){$end_VR++;}
    elsif($end[$i] eq "RT"){$end_RT++;}
}
$start_TR = sprintf("%0.2f",$start_TR/@start);$start_VR = sprintf("%0.2f",$start_VR/@start);$start_RT = sprintf("%0.2f",$start_RT/@start);
$end_TR = sprintf("%0.2f",$end_TR/$sum_TR);$end_VR = sprintf("%0.2f",$end_VR/$sum_VR);$end_RT = sprintf("%0.2f",$end_RT/$sum_RT);

my ($TR_TR,$TR_VR,$TR_RT,$VR_TR,$VR_VR,$VR_RT,$RT_TR,$RT_VR,$RT_RT)=(0,0,0,0,0,0,0,0,0);
for(my $i=0;$i<@trans_TR;$i++){
    if($trans_TR[$i] eq "TR"){$TR_TR++;}
    elsif($trans_TR[$i] eq "VR"){$TR_VR++;}
    elsif($trans_TR[$i] eq "RT"){$TR_RT++;}
}
if(@trans_TR != 0){
    $TR_TR = sprintf("%0.2f",$TR_TR/$sum_TR);$TR_VR = sprintf("%0.2f",$TR_VR/$sum_TR);$TR_RT = sprintf("%0.2f",$TR_RT/$sum_TR);
}
for(my $i=0;$i<@trans_VR;$i++){
    if($trans_VR[$i] eq "TR"){$VR_TR++;}
    elsif($trans_VR[$i] eq "VR"){$VR_VR++;}
    elsif($trans_VR[$i] eq "RT"){$VR_RT++;}
}
if(@trans_VR != 0){
    $VR_TR = sprintf("%0.2f",$VR_TR/$sum_VR);$VR_VR = sprintf("%0.2f",$VR_VR/$sum_VR);$VR_RT = sprintf("%0.2f",$VR_RT/$sum_VR);
}
for(my $i=0;$i<@trans_RT;$i++){
    if($trans_RT[$i] eq "TR"){$RT_TR++;}
    elsif($trans_RT[$i] eq "VR"){$RT_VR++;}
    elsif($trans_RT[$i] eq "RT"){$RT_RT++;}
}
if(@trans_RT != 0){
    $RT_TR = sprintf("%0.2f",$RT_TR/$sum_RT);$RT_VR = sprintf("%0.2f",$RT_VR/$sum_RT);$RT_RT = sprintf("%0.2f",$RT_RT/$sum_RT);
}

print OUT "Start Probability:\n$start_TR\t$start_VR\t$start_RT\n";
print OUT "End Probability:\n$end_TR\t$end_VR\t$end_RT\n";
print OUT "Transition Probability:\n";
print OUT "$TR_TR\t$TR_VR\t$TR_RT\n$VR_TR\t$VR_VR\t$VR_RT\n$RT_TR\t$RT_VR\t$RT_RT\n";
print OUT "Length Statistics:\n";
print OUT "TR:\tmin:$min_len_TR\tavg:$avg_len_TR\tmax:$max_len_TR\n";
print OUT "VR:\tmin:$min_len_VR\tavg:$avg_len_VR\tmax:$max_len_VR\n";
print OUT "RT:\tmin:$min_len_RT\tavg:$avg_len_RT\tmax:$max_len_RT\n";
print OUT "Gap Length Statistics:\n";
print OUT "TR-TR:\tmin:$min_gap_TR_TR\tavg:$avg_gap_TR_TR\tmax:$max_gap_TR_TR\n";
print OUT "TR-VR:\tmin:$min_gap_TR_VR\tavg:$avg_gap_TR_VR\tmax:$max_gap_TR_VR\n";
print OUT "TR-RT:\tmin:$min_gap_TR_RT\tavg:$avg_gap_TR_RT\tmax:$max_gap_TR_RT\n";
print OUT "VR-TR:\tmin:$min_gap_VR_TR\tavg:$avg_gap_VR_TR\tmax:$max_gap_VR_TR\n";
print OUT "VR-VR:\tmin:$min_gap_VR_VR\tavg:$avg_gap_VR_VR\tmax:$max_gap_VR_VR\n";
print OUT "VR-RT:\tmin:$min_gap_VR_RT\tavg:$avg_gap_VR_RT\tmax:$max_gap_VR_RT\n";
print OUT "RT-TR:\tmin:$min_gap_RT_TR\tavg:$avg_gap_RT_TR\tmax:$max_gap_RT_TR\n";
print OUT "RT-VR:\tmin:$min_gap_RT_VR\tavg:$avg_gap_RT_VR\tmax:$max_gap_RT_VR\n";
print OUT "RT-RT:\tmin:$min_gap_RT_RT\tavg:$avg_gap_RT_RT\tmax:$max_gap_RT_RT\n";

print "length\ttype";
foreach my $i(@gap_TR_TR){
    print "$i\tTR-TR\n";
}
foreach my $i(@gap_TR_VR){
    print "$i\tTR-VR\n";
}
foreach my $i(@gap_TR_RT){
    print "$i\tTR-RT\n";
}
foreach my $i(@gap_VR_TR){
    print "$i\tVR-TR\n";
}
foreach my $i(@gap_VR_VR){
    print "$i\tVR-VR\n";
}
foreach my $i(@gap_VR_RT){
    print "$i\tVR-RT\n";
}
foreach my $i(@gap_RT_TR){
    print "$i\tRT-TR\n";
}
foreach my $i(@gap_RT_VR){
    print "$i\tRT-VR\n";
}


close OUT;


sub strstr{
    my ($seq1,$seq2) = @_;
    chomp($seq1);chomp($seq2);
    if(length($seq1) >= length($seq2)){
	for(my $i=0;$i<length($seq1)-length($seq2);$i++){
	    my $sub = substr($seq1,$i,length($seq2));
	    if($sub eq $seq2){
		return $i;
	    }
	}
    }
    else{
	return -1;
    }
    return -1;
}

sub count{
    my (@array) = @_;
    my $size = @array;
    if($size == 0){
	return ("*","*","*");
    }
    else{
	my($min,$avg,$max)=(10000000,0,0);
	for(my $i=0;$i<@array;$i++){
	    if($array[$i] < $min){$min = $array[$i];}
	    if($array[$i] > $max){$max = $array[$i];}
	    $avg += $array[$i];
	}
	$avg /= $size;
	$avg = sprintf("%d",$avg);
	return ($min,$avg,$max);
    }
}
