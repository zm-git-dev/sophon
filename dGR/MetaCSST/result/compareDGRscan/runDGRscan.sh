#!/usr/bin/bash


in=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT155 start at $date $time" >>$in.log

blastx -evalue 1e-3 -outfmt 6 -db RT-155.fa -query $in -out blastx/$in-vs-RT155.m8 -num_threads 1
python DGRscan.py -inseq $in -summary $in-DGRscan-RT155.summary -rev_hom blastx/$in-vs-RT155.m8

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT155 end at $date $time" >>$in.log

#################################################################################################

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT367 start at $date $time" >>$in.log

blastx -evalue 1e-3 -outfmt 6 -db RT-367.fa -query $in -out blastx/$in-vs-RT367.m8 -num_threads 1
python DGRscan.py -inseq $in -summary $in-DGRscan-RT367.summary -rev_hom blastx/$in-vs-RT367.m8

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT367 end at $date $time" >>$in.log

#################################################################################################


date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT1246 start at $date $time" >>$in.log

blastx -evalue 1e-3 -outfmt 6 -db RT-1246.fa -query $in -out blastx/$in-vs-RT1246.m8 -num_threads 1
python DGRscan.py -inseq $in -summary $in-DGRscan-RT1246.summary -rev_hom blastx/$in-vs-RT1246.m8

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "DGRscan-RT1246 end at $date $time" >>$in.log
