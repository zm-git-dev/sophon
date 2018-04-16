#!/bin/bash
#SBATCH -J mageblast
#SBATCH --partition=cpu128
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

obj=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$obj start at $date $time"

blastn -query hg19-seg1k-step1k-4mer-pass.fa -db db/$obj.fna -out blast/seg30M-$obj.megablast -max_target_seqs 1 -outfmt 7 -num_threads 16

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$obj end at $date $time"

exit
