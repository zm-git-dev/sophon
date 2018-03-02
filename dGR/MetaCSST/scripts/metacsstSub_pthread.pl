#!/usr/bin/perl -w
use strict;
use threads;

#This script is the pthread perl scripts to start the program of metacsstSub

my ($build,$in,$tmp,$out,$cpu)= @ARGV;
die "Error with arguments!\nusage: $0 <TR.config/RT.config> <Input FASTA File> <Tmp Directory> <OUT File> <CPU Number>\n" if (@ARGV<5);

#system("chomp $in");
system("mkdir $tmp");
my $num = `grep ">" $in | wc -l`;
my $per = int($num/$cpu) + 1;
open(IN,$in)||die("error\n");

my $count = 0;my $id = 0;
open(OUT,">$tmp/split-$id")||die("error with opening $tmp/split-$id\n");

my $real_cpu = 0;
while(<IN>){
    chomp;
    print OUT "$_\n";
    if($_ !~ />/){
	$count ++;
    }
    if($count==$per){
	$count = 0;
	$id += 1;
	$real_cpu += 1;
	close OUT;
	open(OUT,">$tmp/split-$id")||die("error with opening $tmp/split-$id\n");
    }
    next;
}

my @thread = ();
for(my $i=0;$i<=$real_cpu;$i++){
    my @arg = ($build,"$tmp/split-$i","$tmp/split-$i-metacsst");
    $thread[$i] =  threads->new(\&metacsst,@arg);
}

for(my $i=0;$i<=$real_cpu;$i++){
    $thread[$i]->join;
}

for(my $i=0;$i<=$real_cpu;$i++){
    #system("rm -rf $tmp");
    system("cat $tmp/split-$i-metacsst/out.txt >> $out");
}

sub metacsst{
    my ($build,$in,$out) = @_;
    system("./metacsstSub -build $build -in $in -out $out -thread 1");
}

close IN;close OUT;
exit;
