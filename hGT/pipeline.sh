#!/usr/bin/bash

k=6

if [ 1 == 2 ]
then

# Get HGT sequences according to the genome and HGT annotation in bed format
./getHGTseq.pl data/hg19/GRCh37.primary_assembly.genome.fa data/HGT-in-Human-Genome/material/data/iden40len20.bed iden40len20-hgt.fa
#segment sampled from hg19 reference genome, segment=1k, step=10k
./segment.pl data/hg19/hg19-UCSC.fa 1000 100000 hg19-seg1k-step100k.fa

#calculate k-mer frequencies (k=1,2,3,4)
for ((i=1; i<=$k; i ++))
do
./kmer.pl hg19-seg1k-step100k.fa $i > kmer/hg19-seg1k-step100k-"$i"mer.txt
./kmer.pl iden40len20-hgt.fa $i > kmer/iden40len20-hgt-"$i"mer.txt
nohup ./kmerGenome.pl data/hg19/hg19-UCSC-upercase.fa $i >kmer/hg19-"$i"mer.txt &
done

#compare HGT regions and segments, based on kmer frequencies
for ((i=1; i<=$k; i ++))
do
    ./compare.pl kmer/iden40len20-hgt-"$i"mer.txt kmer/hg19-seg1k-step100k-"$i"mer.txt kmer/hg19-"$i"mer.txt distance-"$i"mer.txt
done

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

# segments from hg19, bouble covering the whole genome, with len=1kbp and step=500bp
./segment.pl data/hg19/hg19-UCSC-upercase.fa 1000 500 hg19-seg1k-step500bp.fa
./kmer.pl hg19-seg1k-step500bp.fa 4 > kmer/hg19-seg1k-step500bp-4mer.txt
./compare.pl kmer/iden40len20-hgt-4mer.txt kmer/hg19-seg1k-step500bp-4mer.txt kmer/hg19-4mer.txt distance-hg19-seg1k-step500bp-4mer.txt
awk '{if($2>0.00825590999999999){print $0}}' distance-hg19-seg1k-step500bp-4mer.txt |grep -v "HGT" |awk '{print $1}' |awk -F '[|-]' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 -k 3n,3 |less >distance-hg19-seg1k-step500bp-4mer-pass.info
./biodiff.pl distance-hg19-seg1k-step500bp-4mer-pass.info iden40len20-hgt.info |wc -l

fi

# segments from hg19, covering the whole genome, with len=1kbp and step=1kbp
#./segment.pl data/hg19/hg19-UCSC-upercase.fa 1000 1000 hg19-seg1k-step1k.txt
#./kmer.pl hg19-seg1k-step1k.txt 4 > kmer/hg19-seg1k-step1k-4mer.txt
./compare.pl kmer/iden40len20-hgt-4mer.txt kmer/hg19-seg1k-step1k-4mer.txt kmer/hg19-4mer.txt distance-hg19-seg1k-step1k-4mer.txt
awk '{if($2>0.00825590999999999){print $0}}' distance-hg19-seg1k-step1k-4mer.txt |grep -v "HGT" |awk '{print $1}' |awk -F '[|-]' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 -k 3n,3 |less >distance-hg19-seg1k-step1k-4mer-pass.info
./biodiff.pl distance-hg19-seg1k-step1k-4mer-pass.info iden40len20-hgt.info |wc -l

## getHit segments
awk '{print $1"|"$2"-"$3}' distance-hg19-seg1k-step1k-4mer-pass.info >mm
filterFa hg19-seg1k-step1k.fa mm distance-hg19-seg1k-step1k-4mer-pass.fa
rm mm