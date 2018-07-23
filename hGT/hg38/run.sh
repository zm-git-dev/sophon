#!/bin/bash

##############
# GRCh38.p10 #
##############

#segments : seg=1kbp, step=800kbp
~/hGT/src/segment.pl fa/hg38.fa 1000 800 segment/hg38-seg1k-step0.8k.fa

#screen : k=4, genome cuttof = top 1%
~/hGT/src/kmerGenome.pl fa/hg38.fa 4 >segment/hg38-4mer.txt  #background, hg38
~/hGT/src/kmer.pl segment/hg38-seg1k-step0.8k.fa 4 >segment/hg38-seg1k-step0.8k-4mer.txt
~/hGT/src/compareKmer.pl segment/hg38-4mer.txt segment/hg38-seg1k-step0.8k-4mer.txt segment/hg38-seg1k-step0.8k-4mer-distance.txt
num=$(grep -v region segment/hg38-seg1k-step0.8k-4mer-distance.txt |wc -l)
top=38446 #$num/100

# top 1% segments
grep -v region segment/hg38-seg1k-step0.8k-4mer-distance.txt |sort -rnk 2 |head -$top |awk '{print $1}' >segment/hg38-seg1k-step0.8k-4mer-distance-pass.info
awk -F '-' '{print $1"\t"$2"\t"$3}' segment/hg38-seg1k-step0.8k-4mer-distance-pass.info |sort -k1,1 -k2n,2 >segment/hg38-seg1k-step0.8k-4mer-distance-pass.bed
~/hGT/src/getHGTseq.pl fa/hg38.fa segment/hg38-seg1k-step0.8k-4mer-distance-pass.bed segment/hg38-seg1k-step0.8k-4mer-distance-pass.fa

#Removing segments overlapped with hg38.simple_repeat.bed
~/hGT/src/biodiff.pl ~/hGT/data/hg38/Simple_repeat-merge.bed segment/hg38-seg1k-step0.8k-4mer-distance-pass.bed |awk '{print $1"-"$2"-"$3}' |sort |uniq >segment/overlap_simple_repeat.info
~/hGT/src/filterFA.pl segment/hg38-seg1k-step0.8k-4mer-distance-pass.fa segment/overlap_simple_repeat.info segment/hg38-seg1k-step0.8k-4mer-distance-pass-masked.fa

#################################################################
# screened segments : 38M.fa                                    #
# Removing sequences overlapped with Simple_repeat.bed : 16M.fa #
#################################################################
cp segment/hg38-seg1k-step0.8k-4mer-distance-pass.fa fa/38M.fa
cp segment/hg38-seg1k-step0.8k-4mer-distance-pass-masked.fa fa/20M.fa



