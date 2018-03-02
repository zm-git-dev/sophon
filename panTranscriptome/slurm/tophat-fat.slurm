#!/bin/bash

#SBATCH -J fusion
#SBATCH --partition=fat
#SBATCH --mail-type=ALL
#SBATCH --exclusive
#SBATCH -n 16
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1
mkdir $i

echo "$i..."  >>$i.log

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "tophat start at $date $time" >>$i.log

~/fzyan/softwares/tophat-2.0.13.Linux_x86_64/tophat2 --fusion-search -p 16 -G ../annotation/gencode.v26.annotation.gtf -o tophat_$i GRCh38.p10  ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "tophat end at $date $time" >>$i.log

exit
