#!/bin/bash

#SBATCH -J GRCh38
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=log/%J.out
#SBATCH --error=log/%J.err

export PATH=$PATH:/usr/bin:/bin

id=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$id LASTZ start at $date $time"

lastz fa/20M.fa[multiple] ~/fzyan/hGT/data/824genome/$id.fna --format=axt+ --output=axt/$id.axt

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$id axt2cov start at $date $time"

~/fzyan/hGT/src/axt2cov.pl cov/$id.cov axt/$id.axt

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "$id complete at $date $time"

exit
