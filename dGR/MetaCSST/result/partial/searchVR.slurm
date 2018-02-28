#!/bin/bash

#SBATCH -J searchVR
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

echo start

tr=$1
sample=$2

echo "$tr-$sample"

./searchVR.pl TR/$tr.TR.fa candidate/$sample-$tr.fa search/$tr.out 3
#grep -v "0\s0" search/$tr.out >tmp-$tr-$sample.out
#mv tmp-$tr-$sample.out search/$tr.out

echo  end

exit
