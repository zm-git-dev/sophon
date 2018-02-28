#!/usr/bin/perl -w
use strict;
use threads;

#This script is used to reBuild the whole DGR structure using multi CPUs,mainly used to search the TR-VR pair
#a completely same TR-VR pair should be retained

#my ($gtf,$ref,$out,$summary,$NAratio,$miss,$LEN,$cpu)= @ARGV;
#die "Error with arguments!\nusage: $0 <Result File In GTF Format> <Ref genome in FASTA format> <OUT File> <OUT summary file> <minNA ratio> <maxNA number> <TR Length Cuttof> <CPU Number>\n" if (@ARGV<7);

my ($gtf,$ref,$out,$NAratio,$miss,$LEN,$cpu)= @ARGV;
die "Error with arguments!\nusage: $0 <Result File In GTF Format> <Ref genome in FASTA format> <OUT File> <minNA ratio> <maxNA number> <TR Length Cuttof> <CPU Number>\n" if (@ARGV<6);

my $num = `grep "DGR" $gtf | wc -l`;
my $per = int($num/$cpu) + 1;
open(GTF,$gtf)||die("error\n");

my $count = 0;my $id = 0;
open(OUT,">$gtf-split-$id")||die("error2\n");

while(<GTF>){
    chomp;
    print OUT "$_\n";
    if($_ =~ /DGR/){
	$count ++;
    }
    if($count==$per){
	$count = 0;
	$id += 1;
	close OUT;
	open(OUT,">$gtf-split-$id")||die("error2\n");
    }
    next;
}

my @thread = ();
for(my $i=0;$i<=$id;$i++){
    my @arg = ("$gtf-split-$i",$ref,"$out-$i",0.5,3,30);
    $thread[$i] =  threads->new(\&reBuild,@arg);
}

for(my $i=0;$i<=$id;$i++){
    $thread[$i]->join;
}

for(my $i=0;$i<=$id;$i++){
    system("cat $out-$i >> $out");
    system("rm $out-$i");
    system("rm $gtf-split-$i");
}

sub reBuild{
    my @data = @_;
    system("./reBuildDGR.pl $data[0] $data[1] $data[2] $data[3] $data[4] $data[5]");
}


close GTF;close OUT;
exit;
