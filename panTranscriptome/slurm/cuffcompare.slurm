#!/bin/bash

#SBATCH -J cuffcompare
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

echo start

~/fzyan/softwares/cufflinks-2.2.1.Linux_x86_64/cuffcompare -o cuffcompare/cuffcompare -s ../annotation/GRCh38.p10.genome.fa -r ../annotation/gencode.v26.annotation.gtf cuffmerge_noRef/merged.gtf

echo  end

exit
