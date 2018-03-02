#!/bin/bash

#SBATCH -J bamCount
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

i=$1
./bamCount.pl $i >>count.txt

exit
