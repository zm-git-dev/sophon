#!/usr/bin/perl -w
use strict;

my ($fusion,$gene,$fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <17fusion.info> <geneInfo.out> <GRCh38.p10.fa> <OUT File>\n" if (@ARGV<4);

open(FUSION,$fusion)||die("error\n");
open(GENE,$gene)||die("error\n");
open(FA,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

my %genome_hash = ();
my %gene_hash = ();

my $id = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$genome_hash{$id} = $_;
    }
}

while(<GENE>){
    chomp();
    my @arr = split(/\s+/,$_);
    $gene_hash{$arr[0]} = $_;
}

while(<FUSION>){
    chomp();
    my @arr = split(/\s+/,$_);
    my ($gene1,$pos1,$gene2,$pos2,$string1,$string2) = ($arr[0],$arr[2],$arr[3],$arr[5],"","");
    if($arr[6] eq "rr"){($string1,$string2) = ("-","-");}
    elsif($arr[6] eq "rf"){($string1,$string2) = ("-","+");}
    elsif($arr[6] eq "ff"){($string1,$string2) = ("+","+");}
    else{($string1,$string2) = ("+","-");}
    
    my @geneinfo1 = split(/\s+/,$gene_hash{$gene1});
    my @geneinfo2 = split(/\s+/,$gene_hash{$gene2});
    my ($start1,$end1,$chr1,$start2,$end2,$chr2) = ($geneinfo1[3],$geneinfo1[4],$geneinfo1[2],$geneinfo2[3],$geneinfo2[4],$geneinfo2[2]);
    
    my ($seq1,$seq2) = ("","");
    if($string1 eq "+"){
	$seq1 = substr($genome_hash{$chr1},$pos1-999,1000);
    }
    else{
	my $seq1_tmp = substr($genome_hash{$chr1},$pos1,1000);
	$seq1 = reverseSeq($seq1_tmp);
    }
    if($string2 eq "+"){
        $seq2 = substr($genome_hash{$chr2},$pos2,1000);
    }
    else{
        my $seq2_tmp = substr($genome_hash{$chr2},$pos2-999,1000);
        $seq2 = reverseSeq($seq2_tmp);
    }
    my $fusion_seq = $seq1.$seq2;
    my $len1 = length($seq1);my $len2 = length($seq2);
    print OUT ">$gene1|$pos1|$gene2|$pos2|$arr[6]|1kbp.1kbp\n$fusion_seq\n";
}

sub reverseSeq{
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

close FUSION;close FA;close GENE;close OUT;
exit;
