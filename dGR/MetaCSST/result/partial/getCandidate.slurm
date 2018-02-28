#!/bin/bash

#SBATCH -J filter
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

echo start

id2=$1
i=$2
pre2=$3
filterFa ~/data/HMP/HMIWGS/fa/$id2.fa $i candidate/$pre2.fa

echo  end

exit
