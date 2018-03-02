#!/bin/bash

#SBATCH -J bam2sam
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

i=$1
samtools view $i/accepted_hits.bam >$i/accepted_hits.sam

echo  end

exit
