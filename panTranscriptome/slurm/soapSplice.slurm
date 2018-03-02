#!/bin/bash

#SBATCH -J soapsplice
#SBATCH --partition=k80
#SBATCH --mail-type=ALL
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1
mkdir $i

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$i soapsplice start at $date $time" >>$i.log

~/fzyan/softwares/SOAPsplice-v1.10/bin/soapsplice -p 20 -d GRCh38.p10.index -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz -2 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz -o $i/soapsplice

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$i soapsplice end at $date $time" >>$i.log
exit
