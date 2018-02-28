#!/usr/bin/perl -w
use strict;

##this is my DGRscan script

my ($fa,$len,$base,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Input Fasta File> <TR length cuttof> <Base> <OUT File>\n" if (@ARGV<4);

open(FILE,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

my ($id,$seq) = ("","");
while(<FILE>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$seq = $_;
	open(TMP,">db/$id.fa")||die("error\n");
	print TMP ">$id\n$seq\n";
	close TMP;

	#system("makeblastdb -in db/$id.fa -dbtype nucl");
	#system("blastn -task blastn -query db/$id.fa -db db/$id.fa -out blast/$id.blastn -evalue 1e-3 -ungapped -word_size 9");

	open(BLAST,"blast/$id.blastn")||die("error\n");
	my ($index,$TR,$VR,$TR_start,$TR_end,$VR_start,$VR_end) = (0,"","",-1,-1,-1,-1);
	while(<BLAST>){
	    chomp();
	    if($_ =~ /Identities\s=\s\d+\/\d+\s\((\d+)%\)/){
		if($TR ne "" && length($TR) >= $len){
		    my $mut = 0;
		    my $yes = 1;
		    for(my $i=0;$i<length($TR);$i++){
			if(substr($TR,$i,1) eq $base && substr($VR,$i,1) ne substr($TR,$i,1)){
			    $mut += 1;
			}
			elsif(substr($TR,$i,1) ne $base && substr($VR,$i,1) ne substr($TR,$i,1)){
			    $yes = 0;
			    last;
			}
		    }
		    if($yes == 1){
			print OUT "$id\tTR\t$TR_start\t$TR_end\t$mut\t$TR\n";
			print OUT "$id\tVR\t$VR_start\t$VR_end\t$mut\t$VR\n";
		    }
		}

		($index,$TR,$VR,$TR_start,$TR_end,$VR_start,$VR_end) = (0,"","",-1,-1,-1,-1);
		my $identity = $1;
		if($identity < 100){
		    $index = 1;
		}
		else{
		    $index = 0;
		}
	    }
	    elsif($_ =~ /Query\s/ && $index == 1){
		my @arr = split(/\s+/,$_);
		if($TR_start == -1){
		    ($TR_start,$TR_end) = ($arr[1],$arr[3]);
		}
		else{
		    $TR_end = $arr[3];
		}
		$TR .= $arr[2];
	    }
	    elsif($_ =~ /Sbjct\s/ && $index == 1){
                my @arr = split(/\s+/,$_);
                if($VR_start ==-1){
                    ($VR_start,$VR_end) = ($arr[1],$arr[3]);
		}
                else{
                    $VR_end = $arr[3];
                }
                $VR .= $arr[2];
            }
	}

	if($TR ne "" && length($TR) >= $len){
	    my $mut = 0;
	    my $yes = 1;
	    for(my $i=0;$i<length($TR);$i++){
		if(substr($TR,$i,1) eq $base && substr($VR,$i,1) ne substr($TR,$i,1)){
		    $mut += 1;
		}
		elsif(substr($TR,$i,1) ne $base && substr($VR,$i,1) ne substr($TR,$i,1)){
		    $yes = 0;
		    last;
		}
	    }	
	    if($yes == 1){
		print OUT "$id\tTR\t$TR_start\t$TR_end\t$mut\t$TR\n";
		print OUT "$id\tVR\t$VR_start\t$VR_end\t$mut\t$VR\n";
	    }
	}

	close BLAST;
    }
}

close FILE;close OUT;
exit;
