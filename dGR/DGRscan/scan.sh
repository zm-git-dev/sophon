#!/usr/bin/bash

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "blast start at $date $time"

blastx -evalue 1e-3 -outfmt 6 -db RT-155.faa -query  ~/dGR/data/virome/GCA_900163725.1_Marine_Virome_Contigs_genomic.fna -out blastx/virome-vs-RT.m8 -num_threads 4

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "blast end at $date $time"

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan start at $date $time"

python DGRscan.py -inseq ~/dGR/data/virome/GCA_900163725.1_Marine_Virome_Contigs_genomic.fna -summary  virome-DGRscan.summary -rev_hom blastx/virome-vs-RT.m8

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan end at $date $time"


exit
