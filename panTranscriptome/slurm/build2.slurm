#!/bin/bash

#SBATCH -J bowtei2
#SBATCH --partition=fat
#SBATCH --mail-user=fazheyan33@163.com
 #SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

bowtie2-build ../annotation/gencode.v26.transcripts.fa gencode.v26.transcripts_index_base

echo  end

exit