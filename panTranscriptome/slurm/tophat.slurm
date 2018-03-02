#!/bin/bash

#SBATCH -J tophat
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 8
#SBATCH --output=%J.out
#SBATCH --error=%J.err


i=$1
mkdir $i

echo "$i..."  >>$i/tophat.log

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "tophat start at $date $time" >>$i/tophat.log

~/fzyan/softwares/tophat-2.0.13.Linux_x86_64/tophat2 -p 8 -G ../annotation/gencode.v26.annotation.gtf -o $i GRCh38_bt2_index_base  ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "tophat end at $date $time" >>$i/tophat.log

exit
