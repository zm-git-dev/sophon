#!/bin/bash

#SBATCH -J 2bwt-builder
#SBATCH --partition=fat
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo "2bwt-builder start"

~/fzyan/softwares/soap2.21release/2bwt-builder ../annotation/gencode.v26.transcripts.fa

echo  "2bwt-builder end"

exit
