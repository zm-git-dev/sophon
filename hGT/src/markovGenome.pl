#!/usr/bin/perl -w
use strict;

## count (K+1)-mer frequencies and get a corresponding K-order markov chain 

my ($genome,$K)= @ARGV;
die "Error with arguments!\nusage: $0 <Genome.fa> <K-order markov model(K value for (k+1)-mer words)>\n" if (@ARGV<2);

if($genome =~ /\.gz/){
    open(GENOME,"gzip -dc $genome|")||die("error");
}
else{
    open(GENOME,$genome)||die("error\n");
}

my %markov = ();
my @keys = ();
my @base = ('A','T','C','G');
@keys = generateKmer($K,@keys);
foreach my $key(@keys){
    my %hash = ();
    foreach my $i(@base){
	$hash{$i} = 0;
    }
    $markov{$key} = \%hash;
}

my $kmer = $K+1;
while(<GENOME>){
    chomp();
    if($_ !~ />/){
	my $seq = $_;
	my $len = length($seq);
	for(my $i=0;$i<$len-$kmer+1;$i++){
	    my $word = substr($seq,$i,$kmer);
	    #my $base = toUperCase(substr($seq,$i,$kmer));
	    my $key1 = substr($word,0,$K);
	    my $key2 = substr($word,$K,1);
	    if(exists($markov{$key1}) and exists(${$markov{$key1}}{$key2})){
		${$markov{$key1}}{$key2} += 1;
	    }
	}
    }
}

foreach my $key1(@keys){
    my $sum = 0;
    foreach my $key2(keys %{$markov{$key1}}){
	$sum += ${$markov{$key1}}{$key2};
    }
    
    foreach my $key2(keys %{$markov{$key1}}){
        my $per = sprintf("%0.4f",${$markov{$key1}}{$key2}/$sum);
	print "$key1 => $key2 : $per\n";
    }
}

sub generateKmer{
    my ($order,@previous) = @_;
    my @append = ();

    if(@previous == 0){
	@append = ('A','T','C','G');
    }
    else{
	my @base = ('A','T','C','G');
	foreach my $item(@previous){
	    foreach my $char(@base){
		my $item2 = $item.$char;
		push(@append,$item2);
	    }
	}
    }

    $order -= 1;
    if($order == 0){
	return @append;
    }
    else{
	generateKmer($order,@append);
    }
}

sub GCpercentage{
    my ($seq) = @_;
    my ($A,$T,$C,$G) = (0,0,0,0);
    my $len = length($seq);
    for(my $i=0;$i<$len;$i++){
	my $base = substr($seq,$i,1);
	if($base eq 'A' || $base eq 'a'){
	    $A += 1;
	}
	elsif($base eq 'T' || $base eq 't'){
	    $T += 1;
	}
	elsif($base eq 'C' || $base eq 'c'){
	    $C += 1;
	}
	elsif($base eq 'G' || $base eq 'g'){
	    $G += 1;
	}
    }
    my $all = $A+$T+$C+$G;
    $A = sprintf("%0.2f",$A/$all);
    $T = sprintf("%0.2f",$T/$all);
    $C = sprintf("%0.2f",$C/$all);
    $G = sprintf("%0.2f",$G/$all);
    return ($A,$T,$C,$G);
}

sub toUperCase{
    my ($seq) = @_;
    my $result = "";
    my $len = length($seq);
    for(my $i=0;$i<$len;$i++){
	my $char = substr($seq,$i,1);
        if($char eq 'a'){
            $result .= 'A';
	}
        elsif($char eq 't'){
            $result .= 'T';
        }
        elsif($char eq 'c'){
            $result .= 'C';
	}
        elsif($char eq 'g'){
            $result .= 'G';
        }
        else{
            $result .= $char;
        }
    }
    return $result;
}

close GENOME;
exit;
