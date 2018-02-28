#!/usr/bin/bash


in=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscanALL start at $date $time" >>$in.log

blastx -evalue 1e-3 -outfmt 6 -db RTall_cdhit0.9_longestORF.fa -query $in -out blastx/$in-vs-RTALL.m8 -num_threads 1

python DGRscan.py -inseq $in -summary $in-DGRscanALL.summary -rev_hom blastx/$in-vs-RTALL.m8


date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscanALL end at $date $time" >>$in.log
