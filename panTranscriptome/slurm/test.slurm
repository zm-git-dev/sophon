#!/bin/bash

#SBATCH -J fusionTest
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH --exclusive
#SBATCH -n 16
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1
mkdir test_tophat_$i

echo start
~/fzyan/softwares/tophat-2.0.13.Linux_x86_64/tophat2 --fusion-search --bowtie1 -p 16 -G ../annotation/gencode.v26.annotation.gtf -o test_tophat_$i GRCh38.p10  ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz
echo end

exit
