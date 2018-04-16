#!/bin/bash

for i in /lustre/home/acct-clswcc/clswcc/fzyan/hGT/db/*.nsq
do
    sbatch blast.slurm $i
done
exit

