#!/bin/bash

#SBATCH -J blastn
#SBATCH --mail-type=ALL
#SBATCH --partition=cpu
#SBATCH -n 1
#SBATCH --output=log/%J.out
#SBATCH --error=log/%J.err

export PATH=$PATH:/usr/bin:/bin

tr=$1
sample=$2
out=$3

echo "$tr-$sample start..."

blastn -task blastn -query ~/data/HMP/HMIWGS/fa/$sample.fa -db TR/$tr.TR.fa -out $out  -evalue 1e-5 -outfmt 6
awk '{print $1}' $out >$out.id

echo "$tr-$sample end..."

exit
