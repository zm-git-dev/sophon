#!/bin/bash

#SBATCH -J bowtei2
#SBATCH --partition=cpu
#SBATCH --mail-user=fazheyan33@163.com
 #SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

bowtie2-build ../annotation/GRCh38.p10.genome.fa GRCh38_bt2_index_base

echo  end

exit