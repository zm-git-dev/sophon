#!/usr/bin/perl -w
use strict;

##this is my DGRscan script

my ($fa,$len,$homo,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Input Fasta File> <TR length cuttof> <Identify> <OUT File>\n" if (@ARGV<4);

open(FILE,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

print OUT "ID\tTR_start\tTR_end\tTR_seq\tVR_start\tVR_end\tVR_seq\tIdentity\tmutA\tmutT\tmutC\tmutG\n";

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
	my ($TR,$VR,$TR_start,$TR_end,$VR_start,$VR_end,$identity) = ("","",-1,-1,-1,-1,0);
	while(<BLAST>){
	    chomp();
	    if($_ =~ /Identities\s=\s\d+\/\d+\s\((\d+)%\)/){
		if($TR ne "" && length($TR) >= $len && $identity >= $homo && $identity < 100){
		    my @mut = (0,0,0,0);#A,T,C,G
		    for(my $i=0;$i<length($TR);$i++){
			my $char1 = substr($TR,$i,1);my $char2 = substr($VR,$i,1);
			if($char1 ne $char2){
			    if($char1 eq 'A'){$mut[0] += 1;}
			    elsif($char1 eq 'T'){$mut[1] += 1;}
			    elsif($char1 eq 'C'){$mut[2] += 1;}
			    else{$mut[3] += 1;}
			}
		    }
		    print OUT "$id\t$TR_start\t$TR_end\t$TR\t$VR_start\t$VR_end\t$VR\t$identity\t$mut[0]\t$mut[1]\t$mut[2]\t$mut[3]\n";
		}
		($TR,$VR,$TR_start,$TR_end,$VR_start,$VR_end,$identity) = ("","",-1,-1,-1,-1,$1);
	    }
	    
	    elsif($_ =~ /Query\s/){
		my @arr = split(/\s+/,$_);
		if($TR_start == -1){
		    ($TR_start,$TR_end) = ($arr[1],$arr[3]);
		}
		else{
		    $TR_end = $arr[3];
		}
		$TR .= $arr[2];
	    }
	    elsif($_ =~ /Sbjct\s/){
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
	close BLAST;
	if($TR ne "" && length($TR) >= $len && $identity >= $homo && $identity < 100){
	    my @mut = (0,0,0,0);#A,T,C,G                                                                                      
	    for(my $i=0;$i<length($TR);$i++){
		my $char1 = substr($TR,$i,1);my $char2 = substr($VR,$i,1);
		if($char1 ne $char2){
		    if($char1 eq 'A'){$mut[0]+=1;}
		    elsif($char1 eq 'T'){$mut[1]+=1;}
		    elsif($char1 eq 'C'){$mut[2]+=1;}
		    else{$mut[3]+=1;}
		}
	    }
	    print OUT "$id\t$TR_start\t$TR_end\t$TR\t$VR_start\t$VR_end\t$VR\t$identity\t$mut[0]\t$mut[1]\t$mut[2]\t$mut[3]\n";
	}
    }
}
close FILE;close OUT;
exit;
