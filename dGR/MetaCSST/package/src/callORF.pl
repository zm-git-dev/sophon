#!/usr/bin/perl -w
use strict;

#This program is used to translate a dna sequence with six different ORFs

my ($cutof,$coden,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Peptide length cuttof (aa) > <src/coden.txt> <INPUT FILES>\n" if (@ARGV<3);
open(RULE,$coden) || die("Can't open coden.txt!\n");
open(LOG,">ORF.info")||die("Can't write to ORF.info!\n");
open(OUT1,">ORF.pro")||die("Can't write to ORF.seq!\n");
open(OUT2,">ORF.dna")||die("Can't write to ORF.dna!\n");

my %translate=();
while(<RULE>){
    chomp();
    my @data = split(/\t/,$_);
    if(not exists $translate{$data[0]}){
	$translate{$data[0]} = $data[1];
    }
    next;
}

our $number = 1;

foreach my $in(@files){
    system("chomp $in");
    open(IN,$in) || die("Can open $in\n");
    my $dna = "";
    my $seq = "";
    while(<IN>){
	chomp();
	if($_ !~ /^$/){
	    if($_ =~ />([^\s]+)/){
		$seq = $1;
		$number = 1;
	    }
	    else{
		my $index = 0;
		$dna = uc($_);
		for(my $i=0;$i<=2;$i++){
		    my $result = translate($in,$seq,$dna,"+",$i,$cutof,%translate);
		    if($result == 1){
			$index = 1;
		    }
		}
		for(my $i=0;$i<=2;$i++){
		    my $result = translate($in,$seq,$dna,"-",$i,$cutof,%translate);
		    if($result == 1){
                        $index = 1;
                    }
		}
		if($index == 1){
		    print  OUT2 ">$seq\n$dna\n";
		}
	    }
	}
	next;
    }
    close IN;
}

sub translate{
    my ($in,$seq,$dna,$string,$frame,$cut,%trans)=@_;
    my $index = 0;
    my $f = $frame +1;
    my $result_index = 0;
    my $pro = "";my $start = 0;my $end = 0;
    if($string eq "+"){
	for(my $i=$frame;$i<=length($dna)-3;$i+=3){
	    my $read = substr($dna,$i,3);
	    if(exists $trans{$read}){
		if($read eq "ATG"){
		    if($index == 0){
			$index = 1;
			$start = $i+1;
		    }
		    $pro .= $trans{$read};
		}
		elsif($trans{$read} eq "STOP"){
		    if($index == 1){
			$end = $i+3;
		    }
		    if(length($pro) >= $cut){
			print  OUT1 ">$seq"."|ORF"."$number\n$pro\n";
			print LOG "$seq"."|ORF"."$number"."\t$string\t$f\t$start\t$end\n";
			$result_index = 1;
			$number += 1;
		    }
		    $index = 0;$pro = "";$start = 0;$end = 0;
		}
		elsif($index == 1){
		    $pro .= $trans{$read};
		}
		if($i+3 > length($dna)-3 && $index == 1 && $end == 0 && length($pro)>$cutof){
		    $end = $i+3;
		    print  OUT1 ">$seq"."|ORF"."$number\n$pro\n";
		    print LOG "$seq"."|ORF"."$number"."\t$string\t$f\t$start\t$end\n";
		    $result_index = 1;
		    $number += 1;
		}
	    }
	    else{
		($index,$start,$end,$pro) = (0,0,0,"");
	    }
	}
    }
    else{
	my %ref=();
	$ref{"A"}="T";$ref{"T"}="A";$ref{"C"}="G";$ref{"G"}="C";
	my $s = "";
	for(my $i = length($dna)-1;$i>=0;$i--){
	    my $new = substr($dna,$i,1);
	    if(exists $ref{$new}){
		$s .= $ref{$new};
	    }
	    else{
		$s .= $new;
	    }
	}
	$dna = $s;
	for(my $i=$frame;$i<=length($dna)-3;$i+=3){
	    my $read = substr($dna,$i,3);
	    if(exists $trans{$read}){
		if($read eq "ATG"){
		    if($index == 0){
			$index = 1;
			$start = length($dna)-$i;
		    }
		    $pro .= $trans{$read};
		}
		elsif($trans{$read} eq "STOP"){
		    if($index == 1){
			$end = length($dna)-$i-2;
		    }
		    if(length($pro) >= $cut){
			print  OUT1 ">$seq"."|ORF"."$number\n$pro\n";
			print LOG "$seq"."|ORF"."$number"."\t$string\t$f\t$start\t$end\n";
			$result_index = 1;
			$number += 1;
		    }
		    $index = 0;$pro = "";$start = 0;$end = 0;
		}
		elsif($index == 1){
		    $pro .= $trans{$read};
		}
		if($i+3 > length($dna)-3 && $index == 1 && length($pro) >= $cutof){
		    $end = length($dna)-$i-2;
		    print  OUT1 ">$seq"."|ORF"."$number\n$pro\n";
		    print LOG "$seq"."|ORF"."$number"."\t$string\t$f\t$start\t$end\n";
		    $result_index = 1;
		    $number += 1;
		}
	    }
	    else{
                ($index,$start,$end,$pro) = (0,0,0,"");
            }
	}
    }
    return $result_index;
}

close RULE;close LOG;close OUT1;close OUT2;
exit;
