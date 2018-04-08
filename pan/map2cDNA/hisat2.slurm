#!/bin/bash

#SBATCH -J hisat2
#SBATCH --partition=cpu128
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

echo start

id=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$id start at $date $time" >>run.log

hisat2 -x 38gene.cDNA.fa -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$id/"$id"_R1_trimmed.fq.gz -2 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$id/"$id"_R2_trimmed.fq.gz -S bam/$id.sam
grep -v "@SQ" bam/$id.sam |awk '{if($3!="*"){print $0}}' >bam/$id-hit.sam
rm bam/$id.sam


date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$id start at $date $time" >>run.log

echo  end

exit
