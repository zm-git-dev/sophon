#!/usr/bin/perl -w
use strict;
use threads;

#LASTZ p_threads

my ($in,$ref,$out,$tmp,$thread)= @ARGV;
die "Error with arguments!\nusage: $0 <Input Fasta File> <Ref Genome> <OUT File> <Temp directory><Threads Number>\n" if (@ARGV<5);

system("mkdir $tmp");

my $num = `grep ">" $in | wc -l`;
my $per = int($num/$thread) + 1;

open(IN,$in)||die("error with opening $in\n");

my $count = 0;my $id = 0;
open(TMP,">$tmp/tmp-$id.fa")||die("error with writing to $tmp/tmp-$id.fa\n");
while(<IN>){
    chomp;
    print TMP "$_\n";
    if($_ !~ />/){
	$count ++;
    }
    if($count==$per){
	$count = 0;
	$id += 1;
	close TMP;
	open(TMP,">$tmp/tmp-$id.fa")||die("error with writing to $tmp/tmp-$id.fa\n");
    }
    next;
}
close TMP;close IN;

my @thread = ();
for(my $i=0;$i<=$id;$i++){
    my @arg = ("$tmp/tmp-$i.fa",$ref,"$tmp/tmp-$i.axt");
    $thread[$i] =  threads->new(\&LASTZ,@arg);
}

for(my $i=0;$i<=$id;$i++){
    $thread[$i]->join;
}

for(my $i=0;$i<=$id;$i++){
    system("cat $tmp/tmp-$i.axt >> $out");
    #system("rm -rf $tmp");
}

sub LASTZ{
    my ($input,$ref,$output) = @_;
    my $search = $input."[multiple]";
    system("lastz $search $ref --format=axt+ --output=$output");
}

exit;
