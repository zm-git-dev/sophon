#!/usr/bin/bash

k=6

if [ 1 == 2 ]
then

# Get HGT sequences according to the genome and HGT annotation in bed format
./getHGTseq.pl data/hg19/GRCh37.primary_assembly.genome.fa data/HGT-in-Human-Genome/material/data/iden40len20.bed iden40len20-hgt.fa
#segment sampled from hg19 reference genome, segment=1k, step=10k
./segment.pl data/hg19/hg19-UCSC.fa 1000 100000 hg19-seg1k-step100k.txt

#calculate k-mer frequencies (k=1,2,3,4)
for ((i=1; i<=$k; i ++))
do
./kmer.pl hg19-seg1k-step100k.txt $i > kmer/hg19-seg1k-step100k-"$i"mer.txt
./kmer.pl iden40len20-hgt.fa $i > kmer/iden40len20-hgt-"$i"mer.txt
nohup ./kmerGenome.pl data/hg19/hg19-UCSC-upercase.fa $i >kmer/hg19-"$i"mer.txt &
done

#compare HGT regions and segments, based on kmer frequencies
for ((i=1; i<=$k; i ++))
do
    ./compare.pl kmer/iden40len20-hgt-"$i"mer.txt kmer/hg19-seg1k-step100k-"$i"mer.txt kmer/hg19-"$i"mer.txt distance-"$i"mer.txt
done

fi

#choose k-mer
num=(1570 628 314 157)
for ((i=1; i<=$k; i ++))
do
    for j in ${num[@]}
    do
	threshold=$(grep "SEG" distance-"$i"mer.txt |sort -rnk 2 |head -$j |tail -n 1 |awk '{print $2}')
	pass=$(grep "HGT" distance-"$i"mer.txt |awk '{if($2>'$threshold'){print $0}}' |wc -l)
	echo -e "$i\t$j\t$pass"
    done
done

