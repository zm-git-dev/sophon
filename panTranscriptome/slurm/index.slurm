#!/bin/bash

#SBATCH -J bwa
#SBATCH --partition=gpu
#SBATCH --mail-user=fazheyan33@163.com
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

echo "genome..."
~/fzyan/softwares/bwa-0.7.8/bwa index -p gencode.v26.transcripts.fa ../annotation/gencode.v26.transcripts.fa

echo "transcriptome..."
~/fzyan/softwares/bwa-0.7.8/bwa index -p GRCh38.p10.genome.fa ../annotation/GRCh38.p10.genome.fa

echo  end

exit
