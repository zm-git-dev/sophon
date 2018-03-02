#!/bin/bash

#SBATCH -J cuffmerge
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

echo start
~/fzyan/softwares/cufflinks-2.2.1.Linux_x86_64/cuffmerge -g ~/fzyan/pan-transcriptome_cancer/annotation/gencode.v26.annotation.gtf -s ~/fzyan/pan-transcriptome_cancer/annotation/GRCh38.p10.genome.fa -o cuffmerge -p 16 assembly_GTF_list.txt

echo  end

exit
