#!/bin/bash

#SBATCH -J primate
#SBATCH --partition=cpu128
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

export PATH=$PATH:/usr/bin:/bin

obj=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$obj start at $date $time"

grep -v "#" blast/seg30M-$obj.megablast |awk '{print $1}' |uniq |sort |uniq >seg30M-noMatch/$obj.match.id
./filterSeg30M.pl hg19-seg1k-step1k-4mer-pass.fa seg30M-noMatch/$obj.match.id seg30M-noMatch/$obj-noMatch.fa

blastn -query seg30M-noMatch/$obj-noMatch.fa -task blastn -db db/$obj.fna -out blast/seg30M-$obj.blastn -max_target_seqs 1 -outfmt 7 -num_threads 16

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$obj end at $date $time"

exit
