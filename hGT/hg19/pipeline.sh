#!/usr/bin/bash

if [ 1 == 2 ] ###code annotation start
then
k=6

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
    ./compareKmer.pl kmer/iden40len20-hgt-"$i"mer.txt kmer/hg19-seg1k-step100k-"$i"mer.txt kmer/hg19-"$i"mer.txt distance-"$i"mer.txt
done

#choose k-mer
num=(1570 628 314 157)
for ((i=1; i<=$k; i ++))
do
    for j in ${num[@]}
    do
	threshold=$(grep "SEG" kmer/distance-"$i"mer.txt |sort -rnk 2 |head -$j |tail -n 1 |awk '{print $2}')
	pass=$(grep "HGT" kmer/distance-"$i"mer.txt |awk '{if($2>'$threshold'){print $0}}' |wc -l)
	echo -e "$i\t$j\t$pass"
    done
done

# segments from hg19, bouble covering the whole genome, with len=1kbp and step=500bp
./segment.pl data/hg19/hg19-UCSC-upercase.fa 1000 500 hg19-seg1k-step500bp.fa
./kmer.pl hg19-seg1k-step500bp.fa 4 > kmer/hg19-seg1k-step500bp-4mer.txt
./compareKmer.pl kmer/iden40len20-hgt-4mer.txt kmer/hg19-seg1k-step500bp-4mer.txt kmer/hg19-4mer.txt distance-hg19-seg1k-step500bp-4mer.txt
awk '{if($2>0.00825590999999999){print $0}}' distance-hg19-seg1k-step500bp-4mer.txt |grep -v "HGT" |awk '{print $1}' |awk -F '[|-]' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 -k 3n,3 |less >distance-hg19-seg1k-step500bp-4mer-pass.info
./biodiff.pl distance-hg19-seg1k-step500bp-4mer-pass.info iden40len20-hgt.info |wc -l

# segments from hg19, covering the whole genome, with len=1kbp and step=1kbp
#./segment.pl data/hg19/hg19-UCSC-upercase.fa 1000 1000 hg19-seg1k-step1k.txt
#./kmer.pl hg19-seg1k-step1k.txt 4 > kmer/hg19-seg1k-step1k-4mer.txt
./compareKmer.pl kmer/iden40len20-hgt-4mer.txt kmer/hg19-seg1k-step1k-4mer.txt kmer/hg19-4mer.txt distance-hg19-seg1k-step1k-4mer.txt
awk '{if($2>0.00825590999999999){print $0}}' distance-hg19-seg1k-step1k-4mer.txt |grep -v "HGT" |awk '{print $1}' |awk -F '[|-]' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 -k 3n,3 |less >distance-hg19-seg1k-step1k-4mer-pass.info
./biodiff.pl distance-hg19-seg1k-step1k-4mer-pass.info iden40len20-hgt.info |wc -l

## getHit segments
awk '{print $1"|"$2"-"$3}' distance-hg19-seg1k-step1k-4mer-pass.info >mm
filterFa hg19-seg1k-step1k.fa mm distance-hg19-seg1k-step1k-4mer-pass.fa
rm mm

for ((i=1; i<=6; i ++))
do
    echo "$i..."
    echo -e "region\tscore\ttype" >>markov/pro-markov-$i.txt
    ./compareMarkov.pl markov/hg19-markov-$i.txt iden40len20-hgt.fa $i |awk '{print $1"\t"$2"\tHGT"}' >>markov/pro-markov-$i.txt
    ./compareMarkov.pl markov/hg19-markov-$i.txt hg19-seg1k-step100k.fa $i |awk '{print $1"\t"$2"\tSEG"}' >>markov/pro-markov-$i.txt
done

num=(1570 628 314 157)
for ((i=1; i<=$k; i ++))
do
    for j in ${num[@]}
    do
        threshold=$(grep "SEG" markov/pro-markov-$i.txt |sort -nk 2 |head -$j |tail -n 1 |awk '{print $2}')
        pass=$(grep "HGT" markov/pro-markov-$i.txt |awk '{if($2<'$threshold'){print $0}}' |wc -l)
        echo -e "$i\t$j\t$pass"
    done
done

###run BLAST, example:
#blastn -task blastn -query hg19-seg1k-step1k-4mer-pass.fa -db db/GCF_000146605.2_Turkey_5.0_genomic.fna -out seg30M-GCF_000146605.2_Turkey_5.0_genomic.fna.blastn -evalue 1e-1 -word_size 7 -outfmt 7 -num_threads 30

#get regions conserved in non-mammal genomes (or mammal genomes)
cd /share/home/user/fzyan/hGT/blast
sh run.sh

## get the common conserved regions in non-mammal genomes, species >=2 and length >=500bp
cd /share/home/user/fzyan/hGT
./region-non-mammal.pl hg19-seg1k-step1k-4mer-pass.fa blast/non-mammal/* >region-non-mammal.out

## get the regions covered by mammal genomes
for i in blast/mammal/GC*-cov.txt
do
    pre=${i#blast/mammal/}
    id=${pre%-cov.txt}
    nohup ./merge-mammal-cov.pl $i blast/mammal/$id-cov-merged.txt &
done

## screen out the regions more conserved in non-mammal genomes
./screen-hgt.pl region-non-mammal.out screen-hgt-0.4.out 0.4 blast/mammal/*merged.txt
awk '{if($4<=8){print $0}}' screen-hgt-0.4.out |awk -F '[\t|-]' '{print $1"\t"$2+$4"\t"$3+$5}' >screen-hgt-0.4-8mammals.info

#blastn: hg19-chr21 to GCF_000090745.1_AnoCar2.0_genomic (Lizard)
#blastn -task blastn -query data/hg19/chromFa/chr21.fa -db db/GCF_000090745.1_AnoCar2.0_genomic.fna -out chr21-GCF_000090745.1_AnoCar2.0_genomic.blastn -max_target_seqs 1 -outfmt 7 -num_threads 32

#blastn -task blastn -query data/hg19/chromFa/chr21.fa -db db/GCF_000090745.1_AnoCar2.0_genomic.fna -out chr21-GCF_000090745.1_AnoCar2.0_genomic-evalue-1-word9.blastn -max_target_seqs 1 -outfmt 7 -num_threads 32 -evalue 1e-1 -word_size 9

blastn -task blastn -query fa/iden40len20.fa -db db/GCF_000146605.2_Turkey_5.0_genomic.fna -out iden40len20-GCF_000146605.2_Turkey_5.0_genomic.fna.blastn -evalue 1e-1 -outfmt 7 -num_threads 32 -perc_identity 40

fi   ###code annotation end

#./src/getHGTseq.pl data/hg19/hg19-UCSC.fa lastz/iden40/nonmammal/screenHGT-8mammal.bed fa/584hgt.fa


#./src/segment.pl data/hg19/hg19-UCSC.fa 2000 20000 segment/hg19-seg2k-step20k.fa
for ((i=1; i<=6; i ++))
do
    ./src/kmer.pl segment/hg19-seg2k-step20k.fa $i > kmer/hg19-seg2k-step20k-"$i"mer.txt
    ./src/kmer.pl fa/584hgt.fa $i > kmer/584hgt-"$i"mer.txt
    ./src/compareKmer.pl kmer/584hgt-"$i"mer.txt kmer/hg19-seg2k-step20k-"$i"mer.txt kmer/hg19-"$i"mer.txt kmer/distance2-"$i"mer.txt

    threshold=$(grep "SEG" kmer/distance2-"$i"mer.txt |sort -rnk 2 |head -1569 |tail -n 1 |awk '{print $2}')
    pass=$(grep "HGT" kmer/distance2-"$i"mer.txt |awk '{if($2>'$threshold'){print $0}}' |wc -l)
    echo -e "$i\t$pass" >>pipeline.out
done


#run lastz:
#lastz seg30M.fa[multiple] data/53genome/$id.fna --format=axt --output=lastz/$id.axt
