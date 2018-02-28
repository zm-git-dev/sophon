#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die "Error with arguments!\nusage: $0 <Result files by DiGReF>\n" if (@ARGV<1);
open(OUT,">annotate.txt")||die("can't write to annotate.txt\n");


print OUT "ID\tType\tStart\tEnd\tLength\tSequence\n";
foreach my $file(@files){
    open(FILE,$file)||die("can't open $file\n");
    my $name="";
    if($file =~ /\/(\d+)/){
	$name = "gi".$1;
    }
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
	    for(my $i=0;$i<@len-1;$i++){
		for(my $j=$i+1;$j<@len;$j++){
		    if($pos[$i] > $pos[$j]){
			my ($a,$b,$c) = ($pos[$j],$len[$j],$type[$j]);
			($pos[$j],$len[$j],$type[$j]) = ($pos[$i],$len[$i],$type[$i]);
			($pos[$i],$len[$i],$type[$i]) = ($a,$b,$c);
		    }
		}
	    }
	    for(my $i=0;$i<@len;$i++){
		my $end_anno = $pos[$i] + $len[$i]-1;
		my $seq_anno = substr($DGR,$pos[$i],$len[$i]);
		print OUT "$name\t$type[$i]\t$pos[$i]\t$end_anno\t$len[$i]\t$seq_anno\n";
	    }
	}
    }
    close FILE;
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
exit;
