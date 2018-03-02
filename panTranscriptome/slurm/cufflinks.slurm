#!/bin/bash

#SBATCH -J cufflinks
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH --exclusive
#SBATCH -n 16
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1

echo "$i..." >>$i.log
date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "cufflinks start at $date $time" >>$i.log

cufflinks -o $i -p 16 -g ../annotation/gencode.v26.annotation.gtf ../tophat2/$i/accepted_hits.bam
date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`

echo "cufflinks end at $date $time" >>$i.log

exit
