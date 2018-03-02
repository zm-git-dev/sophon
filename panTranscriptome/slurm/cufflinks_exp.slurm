#!/bin/bash

#SBATCH -J cufflinks
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1

echo "$i..." >>$i.log
date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "cufflinks start at $date $time" >>$i.log

mkdir cufflinks_exp/$i
cufflinks -o cufflinks_exp/$i -p 1 -G cuffmerge_noRef/merged.gtf ../tophat2/$i/accepted_hits.bam

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`

echo "cufflinks end at $date $time" >>$i.log

exit
