#!/bin/bash

# generate kmer
./src/segment.pl data/hg19/hg19-UCSC.fa 2000 1500 segment/hg19-seg2k-step1.5k.fa
# compute kmer distance with hg19 reference, k=4
./src/kmer.pl segment/hg19-seg2k-step1.5k.fa 4 >kmer/hg19-seg2k-step1.5k-4mer.txt

# choose distance threshold and get filtered segments
./src/compareKmer.pl kmer/hg19-4mer.txt kmer/hg19-seg2k-step1.5k-4mer.txt kmer/dis-hg19-seg2k-step1.5k-4mer.txt

all=$(grep -v region kmer/dis-hg19-seg2k-step1.5k-4mer.txt |wc -l)
#all = 1931969, top 1% : 19320
score=$(grep -v "region" kmer/dis-hg19-seg2k-step1.5k-4mer.txt |sort -rnk 2 |head -19320 |tail -n 1 |awk '{print $2}')
#score = 0.076759
grep -v "region" kmer/dis-hg19-seg2k-step1.5k-4mer.txt |awk '{if($2>=0.076759) print $1}' >segment/hg19-seg2k-step1.5k-4mer-pass.info
