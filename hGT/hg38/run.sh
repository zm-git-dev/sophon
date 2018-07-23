#!/bin/bash

##############
# GRCh38.p10 #
##############



#segments : seg=2k, step=1k
~/hGT/src/segment.pl fa/hg38.fa 1000 800 segment/hg38-seg1k-step0.8k.fa

#screen : k=4, genome cuttof = top 1%
~/hGT/src/kmerGenome.pl fa/hg38.fa 3 >segment/hg38-4mer.txt  #background, hg38
~/hGT/src/kmer.pl segment/hg38-seg1k-step0.8k.fa 4 >segment/hg38-seg1k-step0.8k-4mer.txt
~/hGT/src/compareKmer.pl segment/hg38-4mer.txt segment/hg38-seg1k-step0.8k-4mer.txt segment/hg38-seg1k-step0.8k-4mer-distance.txt

