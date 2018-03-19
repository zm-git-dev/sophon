#!/usr/bin/perl -w
use strict;

## calculating the probability of generating a given sequence according to ht backgrounf markov-model

my ($model,$fa,$K)= @ARGV;
die "Error with arguments!\nusage: $0 <Genome markov model> <Input sequences> <K-order markov model(K value for (k+1)-mer words)\n" if (@ARGV<3);
open(MODEL,$model)||die("error\n");
open(FA,"$fa")||die("error\n");

my %markov = ();
while(<MODEL>){
    chomp();
    my @data = split(/\s+/,$_);
    if(not exists($markov{$data[0]})){
	my @base = ('A','T','C','G');
	my %hash = ();
	foreach my $i(@base){
	    $hash{$i} = 0;
	}
	$markov{$data[0]} = \%hash;
	${$markov{$data[0]}}{$data[2]} = $data[4];
    }
    else{
	${$markov{$data[0]}}{$data[2]} = $data[4];
    }
}

foreach my $key1(keys %markov){
    foreach my $key2(keys %{$markov{$key1}}){
	print "$key1 => $key2 : ${$markov{$key1}}{$key2}\n";
    }
}

my ($kmer,$id) = ($K+1,"","");
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	my ($seq,$score) = ($_,0);
	my $len = length($seq);
	for(my $i=0;$i<$len-$kmer+1;$i++){
	    my $word = substr($seq,$i,$kmer);
	    #my $base = toUperCase(substr($seq,$i,$kmer));
	    my $key1 = substr($word,0,$K);
	    my $key2 = substr($word,$K,1);
	    if(exists($markov{$key1}) and exists(${$markov{$key1}}{$key2})){
		$score += log(${$markov{$key1}}{$key2});
	    }
	}
	my $score = sprintf("%0.4f",$score);
	print "$id\t$score\n";
    }
}


close MODEL;close FA;
exit;
