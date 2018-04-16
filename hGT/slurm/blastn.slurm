#!/bin/bash
#SBATCH -J blast
#SBATCH --partition=cpu128
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

query=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$query start at $date $time"

suf=${query#/lustre/home/acct-clswcc/clswcc/fzyan/hGT/db/}
pre=${suf%.fna.nsq}
blastn -query hg19-seg1k-step1k-4mer-pass.fa -task blastn -db db/$pre.fna -out blast/seg30M-$pre.blastn -max_target_seqs 1 -outfmt 7 -num_threads 16

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$query end at $date $time"

exit
