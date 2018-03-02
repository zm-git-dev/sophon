#!/bin/bash

#SBATCH -J 2bwt
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

~/fzyan/softwares/SOAPsplice-v1.10/bin/2bwt-builder ~/fzyan/pan-transcriptome_cancer/annotation/gencode.v26.transcripts.fa gencode.v26.transcripts

echo  end

exit
