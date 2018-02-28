#!/bin/bash

#SBATCH -J bowtie2
#SBATCH --mail-type=ALL
#SBATCH --partition=cpu
#SBATCH -n 1
#SBATCH --output=log/%J.out
#SBATCH --error=log/%J.err

export PATH=$PATH:/usr/bin:/bin

dgr=$1
sample=$2

echo "$dgr-$sample start..."

bowtie2 --no-unal -f -x dgrFa/$dgr.dgr.fa -U ~/data/human_gut_metagenome/ERP019800/fa/$sample.fa -S bowtie2/$dgr.sam
samtools view -bS bowtie2/$dgr.sam -o bowtie2/$dgr.bam

echo "$dgr-$sample end..."

exit
